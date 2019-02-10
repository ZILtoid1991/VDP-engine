/*
 * Copyright (C) 2015-2017, by Laszlo Szeremi under the Boost license.
 *
 * Pixel Perfect Engine, graphics.fontsets module
 */

module PixelPerfectEngine.graphics.fontsets;
public import PixelPerfectEngine.graphics.bitmap;
public import PixelPerfectEngine.system.exc;
import bmfont;
import dimage.base;
import dimage.tga;
import dimage.png;
public import PixelPerfectEngine.system.binarySearchTree;
static import std.stdio;
/**
 * Stores the letters and all the data associated with the font, also has functions related to text lenght and line formatting. Supports variable letter width.
 * TODO: Build fast kerning table through the use of binary search trees.
 */
public class Fontset(T)
		if(T.stringof == Bitmap8Bit.stringof || T.stringof == Bitmap16Bit.stringof || T.stringof == Bitmap32Bit.stringof){
	public Font 						fontinfo;	///BMFont information on drawing the letters (might be removed later on)
	BinarySearchTree!(dchar, Font.Char)	chars;		///Contains character information in a fast lookup form
	public T[] 							pages;		///Character pages
	private string 						name;
	private int							size;

	/**
	 * Loads a fontset from disk.
	 */
	public this(std.stdio.File file, string basepath = ""){
		import std.path : extension;
		ubyte[] buffer;
		buffer.length = cast(size_t)file.size;
		file.rawRead(buffer);
		fontinfo = parseFnt(buffer);
		foreach(ch; fontinfo.chars){
			chars[ch.id] = ch;
		}
		size = fontinfo.info.fontSize;
		name = fontinfo.info.fontName;
		foreach(path; fontinfo.pages){
			std.stdio.File pageload = std.stdio.File(basepath ~ path);
			switch(extension(path)){
				case ".tga", ".TGA":
					TGA fontPage = TGA.load(pageload);
					if(!fontPage.getHeader.topOrigin){
						fontPage.flipVertical;
					}
					static if(T.stringof == Bitmap8Bit.stringof){
						if(fontPage.getBitdepth != 8)
							throw new BitmapFormatException("Bitdepth mismatch exception!");
						pages ~= new Bitmap8Bit(fontPage.getImageData, fontPage.width, fontPage.height);
					}else static if(T.stringof == Bitmap16Bit.stringof){
						if(fontPage.getBitdepth != 16)
							throw new BitmapFormatException("Bitdepth mismatch exception!");
						pages ~= new Bitmap16Bit(fontPage.getImageData, fontPage.width, fontPage.height);
					}else static if(T.stringof == Bitmap32Bit.stringof){
						if(fontPage.getBitdepth != 32)
							throw new BitmapFormatException("Bitdepth mismatch exception!");
						pages ~= new Bitmap32Bit(fontPage.getImageData, fontPage.width, fontPage.height);
					}
					break;
				case ".png", ".PNG":
					PNG fontPage = PNG.load(pageload);
					static if(T.stringof == Bitmap8Bit.stringof){
						if(fontPage.getBitdepth != 8)
							throw new BitmapFormatException("Bitdepth mismatch exception!");
						pages ~= new Bitmap8Bit(fontPage.getImageData, fontPage.width, fontPage.height);
					}else static if(T.stringof == Bitmap32Bit.stringof){
						if(fontPage.getBitdepth != 32)
							throw new BitmapFormatException("Bitdepth mismatch exception!");
						pages ~= new Bitmap32Bit(fontPage.getImageData, fontPage.width, fontPage.height);
					}
					break;
				default:
					throw new Exception("Unsupported file format!");
			}
		}
	}
	///Returns the name of the font
	public string getName(){
		return name;
	}
	///Returns the height of the font.
	public int getSize(){
		return size;
	}
	///Returns the width of the text.
	public int getTextLength(dstring text){
		int length;
		foreach(c; text){
			length += chars[c].xadvance;
		}
		//writeln(length);
		return length;
	}
	/**
	* Breaks the input text into multiple lines according to the parameters.
	*/
	public dstring[] breakTextIntoMultipleLines(dstring input, int maxWidth, bool ignoreNewLineChars = false){
		dstring[] output;
		dstring currentWord, currentLine;
		int currentWordLength, currentLineLength;

		foreach(character; input){
			currentWordLength += chars[character].xadvance;
			if(!ignoreNewLineChars && (character == FormattingCharacters.newLine || character == FormattingCharacters.carriageReturn)){
				//initialize new line on symbols indicating new lines
				if(currentWordLength + currentLineLength <= maxWidth){
					currentLine ~= currentWord;
					output ~= currentLine;
				}else{
					output ~= currentLine;
					output ~= currentWord;
				}
				currentLine.length = 0;
				currentLineLength = 0;
				currentWord.length = 0;
				currentWordLength = 0;
			}else if(character == FormattingCharacters.space){
				//add new word to the current line if it has enough space, otherwise break the line and initialize next one
				if(currentWordLength + currentLineLength <= maxWidth){
					currentLineLength += currentWordLength;
					currentLine ~= currentWord ~ ' ';
				}else{
					output ~= currentLine;
				}
			}else{
				if(currentWordLength > maxWidth){	//Flush current word if it will be too long for a single line
					output ~= currentWord;
					currentLine.length = 0;
					currentWordLength = 0;
				}
				currentWord ~= character;

			}
		}

		return output;
	}
}

public enum FormattingCharacters : dchar{
	horizontalTab	=	0x9,
	newLine			=	0xA,
	newParagraph	=	0xB,
	carriageReturn	=	0xD,
	space			=	0x20,
}
