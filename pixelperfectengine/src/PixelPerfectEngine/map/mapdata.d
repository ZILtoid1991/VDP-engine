﻿module PixelPerfectEngine.map.mapdata;
/*
 * Copyright (C) 2015-2017, by Laszlo Szeremi under the Boost license.
 *
 * Pixel Perfect Engine, map module
 */
import std.stdio;
import std.file;
import std.conv;
import std.base64;
import PixelPerfectEngine.graphics.bitmap;
import PixelPerfectEngine.graphics.layers;
import PixelPerfectEngine.system.exc;
import core.stdc.stdlib;
import core.stdc.stdio;
import std.string;

version(Windows){
	import core.sys.windows.windows;
	import std.windows.syserror;
}else{
	import core.stdc.errno;
}

public import PixelPerfectEngine.system.exc;
/**
 * Contains the very basic data for the map binary file (*.mbf).
 */
public struct MapDataHeader{
	public uint flags;
	public uint fileLength;	/// fileLength = sizeX * sizeY + MapDataHeader.sizeof;
	public int sizeX;
	public int sizeY;
	this(int sizeX, int sizeY){
		this.fileLength = sizeX * sizeY + MapDataHeader.sizeof;
		this.sizeX = sizeX;
		this.sizeY = sizeY;
	}
}

/**
 * Saves a map to an external file.
 */
public void saveMapFile(MapDataHeader* header, ref MappingElement[] map, string name){
	FILE* outputStream = fopen(toStringz(name), "wb");
	if(outputStream is null){
		import std.conv;
		version(Windows){
			DWORD errorCode = GetLastError();
		}else version(Posix){
			int errorCode = errno;
		}
		throw new FileAccessException("File access error! Error number: " ~ to!string(errorCode));
	}

	fwrite(cast(void*)header, MapDataHeader.sizeof, 1, outputStream);
	fwrite(cast(void*)map.ptr, MappingElement.sizeof, map.length, outputStream);

	fclose(outputStream);
}

/**
 * Loads a map from an external file. Header must be preallocated.
 */
public MappingElement[] loadMapFile(MapDataHeader* header, string name){
	FILE* inputStream = fopen(toStringz(name), "rb");
	MappingElement[] result;
	if(inputStream is null){
		import std.conv;
		version(Windows){
			DWORD errorCode = GetLastError();
		}else version(Posix){
			int errorCode = errno;
		}
		throw new FileAccessException("File access error! Error number: " ~ to!string(errorCode));
	}

	fread(cast(void*)header, MapDataHeader.sizeof, 1, inputStream);
	result.length = header.sizeX * header.sizeY;
	fread(cast(void*)result, MappingElement.sizeof, result.length, inputStream);

	fclose(inputStream);
	return result;
}

/**
 * Loads a map from a BASE64 string.
 */
public MappingElement[] loadMapFromBase64(in char[] input, int length){
	MappingElement[] result;
	result.length = length;
	Base64.decode(input, cast(ubyte[])cast(void[])result);
	return result;
}

/**
 * Saves a map to a BASE64 string.
 */
public char[] saveMapToBase64(in MappingElement[] input){
	char[] result;
	Base64.encode(cast(ubyte[])cast(void[])input, result);
	return result;
}