/*
Copyright (C) 2015, by Laszlo Szeremi under the Boost license.

VDP Engine
*/


module app;

import std.stdio;
import std.string;
import std.conv;
import std.random;

import bindbc.sdl;
//import derelict.freeimage.freeimage;

//import system.config;

import PixelPerfectEngine.graphics.outputScreen;
import PixelPerfectEngine.graphics.raster;
import PixelPerfectEngine.graphics.layers;

import PixelPerfectEngine.graphics.bitmap;
//import PixelPerfectEngine.collision;
import PixelPerfectEngine.system.inputHandler;
import PixelPerfectEngine.system.file;
import PixelPerfectEngine.system.etc;
import PixelPerfectEngine.system.config;
//import PixelPerfectEngine.system.binarySearchTree;
import PixelPerfectEngine.system.common;

public import editor;
//import PixelPerfectEngine.extbmp.extbmp;

public Editor prg;

int main(string[] args){
	initialzeSDL();

	if (args.length > 1) {
		if (args[1] == "--test") {
			bool testTransformableTileLayer;
			if (args.length > 2) 
				if (args[2] == "transform")
					testTransformableTileLayer = true;
			TileLayerTest lprg = new TileLayerTest(testTransformableTileLayer);
			lprg.whereTheMagicHappens;
			return 0;
		}
	}

	prg = new Editor(args);
	prg.whereTheMagicHappens;
	return 0;
}

class TileLayerTest : SystemEventListener, InputListener{
	bool isRunning, up, down, left, right, scrup, scrdown, scrleft, scrright;
	OutputScreen output;
	Raster r;
	TileLayer t;
	TileLayer text;
	TransformableTileLayer!(Bitmap8Bit,16,16) tt;
	Bitmap8Bit[] tiles;
	Bitmap8Bit dlangMan;
	SpriteLayer s;
	InputHandler ih;
	float theta;
	this(bool testTransformableTileLayer = false){
		theta = 0;
		isRunning = true;
		Image tileSource = loadImage(File("../assets/sci-fi-tileset.png"));
		//Image tileSource = loadImage(File("../assets/_system/concreteGUIE0.tga"));
		Image spriteSource = loadImage(File("../assets/d-man.tga"));
		output = new OutputScreen("TileLayer test", 1280,960);
		r = new Raster(320,240,output,0);
		output.setMainRaster(r);
		t = new TileLayer(16,16, LayerRenderingMode.COPY);
		tt = new TransformableTileLayer!(Bitmap8Bit,16,16)(LayerRenderingMode.COPY);
		s = new SpriteLayer(LayerRenderingMode.ALPHA_BLENDING);
		if (testTransformableTileLayer) r.addLayer(tt, 0);
		else r.addLayer(t, 0);
		r.addLayer(s, 1);
		//c = new CollisionDetector();
		dlangMan = loadBitmapFromImage!Bitmap8Bit(spriteSource);
		//CollisionModel cm = new CollisionModel(dlangMan.width, dlangMan.height, dlangMan.generateStandardCollisionModel());
		dlangMan.offsetIndexes(256,false);
		s.addSprite(dlangMan, 65, 0, 0, 1);
		//s.scaleSpriteHoriz(0,-1024);
		//s.scaleSpriteVert(0,-1024);
		for(int i = 1 ; i < 10 ; i++){
			const bool check = s.addSprite(dlangMan, i, uniform(0,320), uniform(0,240), 1);
			//assert(check, "DisplayList Error!");
		}
		//s.collisionDetector[1] = c;
		//c.source = s;
		//c.addCollisionModel(cm,0);
		//c.addCollisionModel(cm,1);
		//c.addCollisionListener(this);
		//tiles.length = tileSource.bitmapID.length;
		tiles = loadBitmapSheetFromImage!Bitmap8Bit(tileSource, 16, 16);//loadBitmapSheetFromFile!Bitmap8Bit("../assets/sci-fi-tileset.png",16,16);
		//tiles = loadBitmapSheetFromFile!(Bitmap8Bit)("../assets/sci-fi-tileset.png", 16, 16);
		if (testTransformableTileLayer) {
			for (int i; i < tiles.length; i++) {
				tt.addTile(tiles[i], cast(wchar)i);
			}
		} else {
			for (int i; i < tiles.length; i++) {
				t.addTile(tiles[i], cast(wchar)i);
			}
		}
		
		//wchar[] mapping;
		MappingElement[] mapping;
		mapping.length = 64*64;
		//attrMapping.length = 256*256;
		for(int i; i < mapping.length; i++){
			//mapping[i] = to!wchar(uniform(0x0000,0x00AA));
			const int rnd = uniform(0,1024);
			//attrMapping[i] = BitmapAttrib(rnd & 1 ? true : false, rnd & 2 ? true : false);
			mapping[i] = MappingElement(cast(wchar)(rnd & 63), BitmapAttrib(rnd & 1024 ? true : false, rnd & 512 ? true : false));
			//mapping[i] = MappingElement(0x0, BitmapAttrib(false,false));
		}
		ih = new InputHandler();
		ih.sel ~= this;
		ih.il ~= this;
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_UP,0, "up", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_DOWN,0, "down", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_LEFT,0, "left", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, SDL_SCANCODE_RIGHT,0, "right", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.np8,0, "scrup", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.np2,0, "scrdown", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.np4,0, "scrleft", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.np6,0, "scrright", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F1,0, "A+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F2,0, "A-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F3,0, "B+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F4,0, "B-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F5,0, "C+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F6,0, "C-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F7,0, "D+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F8,0, "D-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F9,0, "x0+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.F10,0, "x0-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.PAGEUP,0, "y0+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.PAGEDOWN,0, "y0-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.NP_PLUS,0, "theta+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.NP_MINUS,0, "theta-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.n1,0, "sV+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.n2,0, "sV-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.n3,0, "sH+", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.n4,0, "sH-", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.Q,0, "HM", Devicetype.KEYBOARD, KeyModifier.All);
		ih.kb ~= KeyBinding(0, ScanCode.W,0, "VM", Devicetype.KEYBOARD, KeyModifier.All);
		if (testTransformableTileLayer) {
			tt.loadMapping(64,64,mapping);
			tt.warpMode = false;
		} else {
			t.loadMapping(64,64,mapping);
			t.warpMode = false;
		}
		//t.setWrapMode(true);
		//tt.D = -256;
		//loadPaletteFromXMP(tileSource, "default", r);

		/*for(int y ; y < 240 ; y++){
			for(int x ; x < 240 ; x++){
				writeln('[',x,',',y,"] : ", t.transformFunc([x,y]));
			}
		}*/
		Color[] localPal = loadPaletteFromImage(tileSource);
		localPal.length = 256;
		r.addPaletteChunk(localPal);
		localPal = loadPaletteFromImage(spriteSource);
		localPal.length = 256;
		r.addPaletteChunk(localPal);
		//r.palette[0].alpha = 255;
		r.palette[256].base = 0;
		//writeln(tt);
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
			if(up) s.relMoveSprite(65,0,-1);
			if(down) s.relMoveSprite(65,0,1);
			if(left) s.relMoveSprite(65,-1,0);
			if(right) s.relMoveSprite(65,1,0);
			
			if(scrup) t.relScroll(0,-1);
			if(scrdown) t.relScroll(0,1);
			if(scrleft) t.relScroll(-1,0);
			if(scrright) t.relScroll(1,0);
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
		import PixelPerfectEngine.graphics.transformFunctions;
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
			case "sH-":
				if(s.getScaleSpriteHoriz(0) == 16){
					s.scaleSpriteHoriz(0,-16);
					return;
				}
				s.scaleSpriteHoriz(0,s.getScaleSpriteHoriz(0) - 16);
				//writeln(s.getScaleSpriteHoriz(0));
				break;
			case "sH+":
				if(s.getScaleSpriteHoriz(0) == -16){
					s.scaleSpriteHoriz(0,16);
					return;
				}
				s.scaleSpriteHoriz(0,s.getScaleSpriteHoriz(0) + 16);
				//writeln(s.getScaleSpriteHoriz(0));
				break;
			case "sV-":
				if(s.getScaleSpriteVert(0) == 16){
					s.scaleSpriteVert(0,-16);
					return;
				}
				s.scaleSpriteVert(0,s.getScaleSpriteVert(0) - 16);
				break;
			case "sV+":
				if(s.getScaleSpriteVert(0) == -16){
					s.scaleSpriteVert(0,16);
					return;
				}
				s.scaleSpriteVert(0,s.getScaleSpriteVert(0) + 16);
				break;
			case "HM":
				s.scaleSpriteHoriz(0,s.getScaleSpriteHoriz(0) * -1);
				break;
			case "VM":
				s.scaleSpriteVert(0,s.getScaleSpriteVert(0) * -1);
				break;
			case "theta+":
				theta += 1;
				short[4] newTP = rotateFunction(theta);
				tt.A = newTP[0];
				tt.B = newTP[1];
				tt.C = newTP[2];
				tt.D = newTP[3];
				break;
			case "theta-":
				theta -= 1;
				short[4] newTP = rotateFunction(theta);
				tt.A = newTP[0];
				tt.B = newTP[1];
				tt.C = newTP[2];
				tt.D = newTP[3];
				break;
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