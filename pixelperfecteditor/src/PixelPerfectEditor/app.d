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
//import PixelPerfectEngine.collision;
import PixelPerfectEngine.system.inputHandler;
import PixelPerfectEngine.system.file;
import PixelPerfectEngine.system.etc;
//import system.tgaconv;
import PixelPerfectEngine.system.config;
import PixelPerfectEngine.system.binarySearchTree;

import editor;
import PixelPerfectEngine.extbmp.extbmp;

version(Windows){
	static const string sdlSource = "system\\SDL2.dll";
	static const string fiSource = "system\\FreeImage.dll";
}else{
	static const string sdlSource = "/system/SDL2.so";
	static const string fiSource = "/system/FreeImage.so";
}

static this(){
	
	DerelictSDL2.load(sdlSource);
	DerelictFI.load(fiSource);
}

static ~this(){
	
	//DerelictSDL2.unload();
	//DerelictFI.unload();
}

int main(string[] args){
	//stdout.flush;
    /*DerelictSDL2.load(sdlSource);
	DerelictFI.load(fiSource);*/
	
	//printf("aaaaaaaaaaaaaaaaaa");
	SDL_SetHint(SDL_HINT_WINDOWS_DISABLE_THREAD_NAMING, "1");
	
	Editor e = new Editor(args);
	e.whereTheMagicHappens;
    //e.destroy();
	//SDL_Quit();
	//testAdvBitArrays(128);
	//TileLayerTest prg = new TileLayerTest();
	//prg.whereTheMagicHappens;
	//testBinarySearchTrees(11, 1);
	return 0;
}

void testBinarySearchTrees(int nOfElements, int nOfTimes){
	for(int i; i < nOfTimes; i++){
		writeln("start test no.",i);
		BinarySearchTree!(int,int) sequ, rand;
		//sequential element test
		for(int j; j < nOfElements; j++){
			sequ[j] = j;
		}
		writeln(sequ);
		//randomized element test
		for(int j; j < nOfElements; j++){
			int k = uniform(short.min,short.max);
			rand[k] = k;
		}
		writeln(rand);
		//rand.optimize();
		//writeln(rand);
	}
	readln();
}

class TileLayerTest : SystemEventListener, InputListener{
	bool isRunning, up, down, left, right, scrup, scrdown, scrleft, scrright;
	OutputScreen output;
	Raster r;
	TileLayer t;
	TransformableTileLayer!(Bitmap16Bit,32,32) tt;
	ABitmap[] tiles;
	Bitmap16Bit dlangMan;
	SpriteLayer s;
	//Bitmap16Bit[wchar] tiles;
	InputHandler ih;
	float theta;
	//CollisionDetector c;
	this(){
		theta = 0;
		isRunning = true;
		ExtendibleBitmap tileSource = new ExtendibleBitmap("tiletest.xmp");
		ExtendibleBitmap spriteSource = new ExtendibleBitmap("collisionTest.xmp");
		//t = new TileLayer(32,32, LayerRenderingMode.COPY);
		tt = new TransformableTileLayer!(Bitmap16Bit,32,32)(LayerRenderingMode.COPY);
		s = new SpriteLayer(LayerRenderingMode.ALPHA_BLENDING);
		//c = new CollisionDetector();
		dlangMan = loadBitmapFromXMP!Bitmap16Bit(spriteSource,"DLangMan");
		//CollisionModel cm = new CollisionModel(dlangMan.width, dlangMan.height, dlangMan.generateStandardCollisionModel());
		dlangMan.offsetIndexes(256,false);
		s.addSprite(dlangMan,0,0,0,BitmapAttrib(false,false));
		for(int i = 1 ; i < 2 ; i++){
			s.addSprite(dlangMan,i,uniform(-31,320),uniform(-31,240),BitmapAttrib(false,false));
		}
		//s.collisionDetector[1] = c;
		//c.source = s;
		//c.addCollisionModel(cm,0);
		//c.addCollisionModel(cm,1);
		//c.addCollisionListener(this);
		tiles.length = tileSource.bitmapID.length;
		for(int i; i < tileSource.bitmapID.length; i++){
			string hex = tileSource.bitmapID[i];
			//writeln(hex[hex.length-4..hex.length]);
			ABitmap ab = loadBitmapFromXMP!Bitmap16Bit(tileSource, hex);
			tiles[i] = ab;
			tt.addTile(ab, to!wchar(parseHex(hex[hex.length-4..hex.length])));
		}
		//wchar[] mapping;
		MappingElement[] mapping;
		mapping.length = 8*8;
		//attrMapping.length = 256*256;
		for(int i; i < mapping.length; i++){
			//mapping[i] = to!wchar(uniform(0x0000,0x00AA));
			int rnd = uniform(0,1024);
			//attrMapping[i] = BitmapAttrib(rnd & 1 ? true : false, rnd & 2 ? true : false);
			mapping[i] = MappingElement(to!wchar(uniform(0x0000,0x00AA)), BitmapAttrib(rnd & 1 ? true : false, rnd & 2 ? true : false));
		}
		ih = new InputHandler();
		ih.sel ~= this;
		ih.il ~= this;
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_UP,0, "up", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_DOWN,0, "down", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_LEFT,0, "left", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_RIGHT,0, "right", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.np8,0, "scrup", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.np2,0, "scrdown", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.np4,0, "scrleft", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.np6,0, "scrright", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F1,0, "A+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F2,0, "A-", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F3,0, "B+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F4,0, "B-", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F5,0, "C+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F6,0, "C-", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F7,0, "D+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F8,0, "D-", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F9,0, "x0+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.F10,0, "x0-", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.PAGEUP,0, "y0+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.PAGEDOWN,0, "y0-", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.NP_PLUS,0, "theta+", Devicetype.KEYBOARD, KeyModifier.ANY);
		ih.kb ~= KeyBinding(0, ScanCode.NP_MINUS,0, "theta-", Devicetype.KEYBOARD, KeyModifier.ANY);

		tt.loadMapping(8,8,mapping);
		//tt.setWarpMode(true);
		//tt.hBlankInterrupt = &ttlHBlankInterrupt;
		//t.setWrapMode(true);

		output = new OutputScreen("TileLayer test", 1280,960);
		r = new Raster(320,240,output);
		output.setMainRaster(r);
		loadPaletteFromXMP(tileSource, "default", r);
		/*for(int y ; y < 240 ; y++){
			for(int x ; x < 240 ; x++){
				writeln('[',x,',',y,"] : ", t.transformFunc([x,y]));
			}
		}*/
		r.addLayer(tt, 0);
		r.addLayer(s, 1);
		r.palette ~= cast(Color[])spriteSource.getPalette("default");
		r.palette[0].alpha = 255;
		r.palette[256].raw = 0;
		writeln(tt);
		//r.palette[0] = 255;
		//r.addRefreshListener(output, 0);
		
	}
	private @nogc void ttlHBlankInterrupt(ref short[4] localABCD, ref short[2] localsXsY, ref short[2] localx0y0, short y){
		localABCD[0]++;
	}
	public void whereTheMagicHappens(){
		while(isRunning){
			r.refresh();
			ih.test();
			if(up) s.relMoveSprite(0,0,-1);
			if(down) s.relMoveSprite(0,0,1);
			if(left) s.relMoveSprite(0,-1,0);
			if(right) s.relMoveSprite(0,1,0);
			if(scrup) tt.relScroll(0,-1);
			if(scrdown) tt.relScroll(0,1);
			if(scrleft) tt.relScroll(-1,0);
			if(scrright) tt.relScroll(1,0);
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
			case "scrup": scrup = true; break;
			case "scrdown": scrdown = true; break;
			case "scrleft": scrleft = true; break;
			case "scrright": scrright = true; break;
			case "A+": tt.A = cast(short)(tt.A + 16); 
				break;
			case "A-": tt.A = cast(short)(tt.A - 16); 
				break;
			case "B+": tt.B = cast(short)(tt.B + 16); break;
			case "B-": tt.B = cast(short)(tt.B - 16); break;
			case "C+": tt.C = cast(short)(tt.C + 16); break;
			case "C-": tt.C = cast(short)(tt.C - 16); break;
			case "D+": tt.D = cast(short)(tt.D + 16); break;
			case "D-": tt.D = cast(short)(tt.D - 16); break;
			case "x0+": tt.x_0 = cast(short)(tt.x_0 + 1); break;
			case "x0-": tt.x_0 = cast(short)(tt.x_0 - 1); break;
			case "y0+": tt.y_0 = cast(short)(tt.y_0 + 1); break;
			case "y0-": tt.y_0 = cast(short)(tt.y_0 - 1); break;
			/*case "theta+": theta += 1; tt.rotate(theta); break;
			case "theta-": theta -= 1; tt.rotate(theta); break;*/
			default: break;
		}
	}
	override public void keyReleased(string ID,uint timestamp,uint devicenumber,uint devicetype) {
		switch(ID){
			case "up": up = false; break;
			case "down": down = false; break;
			case "left": left = false; break;
			case "right": right = false; break;
			case "scrup": scrup = false; break;
			case "scrdown": scrdown = false; break;
			case "scrleft": scrleft = false; break;
			case "scrright": scrright = false; break;
			default: break;
		}
	}
/*public void spriteCollision(CollisionEvent ce){
		writeln("COLLISION!!!!11!1111!!!ONEONEONE!!!");
	}
	
	public void backgroundCollision(CollisionEvent ce){}*/
}