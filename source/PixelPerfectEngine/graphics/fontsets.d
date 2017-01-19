/*
 * Copyright (C) 2015-2017, by Laszlo Szeremi under the Boost license.
 *
 * Pixel Perfect Engine, graphics.fontsets module
 */

module PixelPerfectEngine.graphics.fontsets;
public import PixelPerfectEngine.graphics.bitmap;

public class Fontset{
	public Bitmap16Bit[wchar] letters/*, mask*/;
	private string name;
	private int size;
	public this(string name, int size, Bitmap16Bit[wchar] letters){
		this.name = name;
		this.size = size;
		this.letters = letters;
		/*foreach(wchar c; letters.byKey){
			mask[c] = new Bitmap16Bit(letters[c].getX,letters[c].getY);
			ushort* psrc = mask[c].getPtr, pdest = letters[c].getPtr;
			for(int i; i < letters[c].getX*letters[c].getY; i++){
				if(*(pdest + i) == 0x0){
					*(psrc + i) = 0xFFFF;
				}
			}
		}*/
	}
	
	public string getName(){
		return name;
	}
	
	public int getSize(){
		return size;
	}

	public int getTextLength(wstring text){
		int length;
		for(int i ; i < text.length ; i++){
			length += letters[text[i]].getX;
		}
		return length;
	}

	//public static Fontset loadFontsetFromFile(string filename){}
	
	//public static Fontset loadFontsetFromBytestream(void[] data){}
	
	
}

public enum FormattingCharacters : wchar{
	horizontalTab	=	0x9,
	newLine			=	0xA,
	newParagraph	=	0xB,
}