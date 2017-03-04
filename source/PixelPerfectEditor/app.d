/*
Copyright (C) 2015, by Laszlo Szeremi under the Boost license.

VDP Engine
*/


module app;

import std.stdio;
import std.string;
import std.conv;
import std.random;

import derelict.sdl2.sdl;
import derelict.freeimage.freeimage;

//import system.config;

import PixelPerfectEngine.graphics.outputScreen;
import PixelPerfectEngine.graphics.raster;
import PixelPerfectEngine.graphics.layers;

import PixelPerfectEngine.graphics.bitmap;
import PixelPerfectEngine.collision;
import PixelPerfectEngine.system.inputHandler;
import PixelPerfectEngine.system.file;
import PixelPerfectEngine.system.etc;
//import system.tgaconv;
import PixelPerfectEngine.system.config;
import PixelPerfectEngine.system.advBitArray;

import editor;
import PixelPerfectEngine.extbmp.extbmp;

int main(string[] args)
{

    DerelictSDL2.load();
	DerelictFI.load();
	
	Editor e = new Editor(args);
	/*ConfigurationProfile cfg = new ConfigurationProfile();
	cfg.autodetectVideoModes(0);
	writeln (cfg.getNumOfVideoModes());
	for(int i = cfg.getNumOfVideoModes() - 1 ; i >= 0 ; i--){
		writeln(cfg.videoModeToString(i));
	}*/
	e.whereTheMagicHappens;
    
	//testAdvBitArrays(128);
	//TileLayerUnittest prg = new TileLayerUnittest();
	return 0;
}

void testAdvBitArrays(int l){
	//General rule: at every step, write all the results to the screen
	//step 1: Generate 4 bitarrays with the l length
	AdvancedBitArray[4] ba;
	for(int i; i < ba.length; i++){
		int x = (l/8)+1;
		void[] rawData;
		rawData.length = x;
		for(int j; j < l/8 ; j++){
			ubyte b = to!ubyte(uniform(0,255));
			*cast(ubyte*)(rawData.ptr + j) = b;
		}
		ba[i] = new AdvancedBitArray(rawData,l);
		writeln(ba[i].toString());
	}
	//step 2: And, or, and then xor all the arrays together
	for(int i; i < ba.length; i++){
		for(int j; j < ba.length; j++){
			AdvancedBitArray resand = ba[i] & ba[j], resor = ba[i] | ba[j], resxor = ba[i] ^ ba[j];
			writeln(resand.toString());writeln(resor.toString());writeln(resxor.toString());
		}
	}//*/
	//step 3: Test bit shifting in both ways by 13
	/*for(int i; i < ba.length; i++){
		AdvancedBitArray shl = ba[i]<<5, shr = ba[i]>>5, sl = ba[i][1..50];
		writeln(shl.toString());
		writeln(shr.toString());
		writeln(sl.toString());
	}//*/
	ubyte[16] testdata = [0,0,81,51,186,186,0,86,48,82,35,5,99,208,95,9];
	ba[0] = new AdvancedBitArray(cast(void[])testdata,128);
	ba[1] = new AdvancedBitArray(cast(void[])testdata,128);
	for(int i ; i < 32 ; i++){
		writeln(ba[0].test(i,40,ba[1],16));
	}
}

class TileLayerUnittest : SystemEventListener, InputListener{
	bool isRunning, up, down, left, right;
	OutputScreen output;
	Raster r;
	TileLayer t;
	//Bitmap16Bit[wchar] tiles;
	InputHandler ih;
	this(){
		isRunning = true;
		ExtendibleBitmap tileSource = new ExtendibleBitmap("tiletest.xmp");
		t = new TileLayer(32,32, LayerRenderingMode.ALPHA_BLENDING);
		for(int i; i < tileSource.bitmapID.length; i++){
			string hex = tileSource.bitmapID[i];
			//writeln(hex[hex.length-4..hex.length]);
			t.addTile(loadBitmapFromXMP(tileSource, hex), to!wchar(parseHex(hex[hex.length-4..hex.length])));
		}
		wchar[] mapping;
		mapping.length = 256*256;
		for(int i; i < mapping.length; i++){
			mapping[i] = to!wchar(uniform(0x0000,0x00AA));
		}
		ih = new InputHandler();
		ih.sel ~= this;
		ih.il ~= this;
		ih.kb ~= KeyBinding(4096, SDL_SCANCODE_UP,0, "up", Devicetype.KEYBOARD);
		ih.kb ~= KeyBinding(4096, SDL_SCANCODE_DOWN,0, "down", Devicetype.KEYBOARD);
		ih.kb ~= KeyBinding(4096, SDL_SCANCODE_LEFT,0, "left", Devicetype.KEYBOARD);
		ih.kb ~= KeyBinding(4096, SDL_SCANCODE_RIGHT,0, "right", Devicetype.KEYBOARD);

		t.loadMapping(256,256,mapping);

		output = new OutputScreen("Tile Layer Unittest", 1280,960);
		r = new Raster(320,240,output);
		output.setMainRaster(r);
		loadPaletteFromXMP(tileSource, "default", r);
		r.addLayer(t, 0);
		r.palette[0] = 255;
		//r.addRefreshListener(output, 0);
		while(isRunning){
			r.refresh();
			ih.test();
			if(up) t.relScroll(0, 1);
			if(down) t.relScroll(0, -1);
			if(left) t.relScroll(1, 0);
			if(right) t.relScroll(-1, 0);
			//t.relScroll(1,0);
		}
	}
	override public void onQuit() {
		isRunning = false;
	}
	override public void controllerAdded(uint ID) {
		
	}
	override public void controllerRemoved(uint ID) {
		
	}
	override public void keyPressed(string ID,uint timestamp,uint devicenumber,uint devicetype) {
		//writeln(ID);
		switch(ID){
			case "up": up = true; break;
			case "down": down = true; break;
			case "left": left = true; break;
			case "right": right = true; break;
			default: break;
		}
	}
	override public void keyReleased(string ID,uint timestamp,uint devicenumber,uint devicetype) {
		switch(ID){
			case "up": up = false; break;
			case "down": down = false; break;
			case "left": left = false; break;
			case "right": right = false; break;
			default: break;
		}
	}

}