module about;

import PixelPerfectEngine.concrete.window;
import PixelPerfectEngine.graphics.common;
import PixelPerfectEngine.system.systemUtility;

immutable wstring verInfo = "0.9.4"w;

public class AboutWindow : Window { 
	Label label1;
	Label label2;
	Label label3;
	Label label4;
	Label label5;
	Label label6;
	Label label7;
	Button buttonClose;
	this(){
		super(Coordinate(0, 0, 305, 185), "About"w);
		label1 = new Label("PixelPerfectEditor"w, "label1", Coordinate(5, 20, 320, 40));
		label2 = new Label("Version: "w ~ verInfo, "label2", Coordinate(5, 40, 300, 60));
		label3 = new Label("Build date: "w, "label3", Coordinate(5, 60, 300, 80));
		label4 = new Label("Engine ver.: "w ~ engineVer, "label4", Coordinate(5, 80, 300, 100));
		label5 = new Label("SDL2 ver.: "w ~ sdlVer, "label5", Coordinate(5, 100, 300, 120));
		label6 = new Label("System/OS: "w ~ osInfo, "label6", Coordinate(5, 120, 300, 140));
		label7 = new Label("Rendering method: "w ~ renderInfo, "label7", Coordinate(5, 140, 300, 160));
		buttonClose = new Button("Close"w, "buttonClose", Coordinate(231, 160, 300, 180));
		buttonClose.onMouseLClickRel = &buttonClose_onMouseLClickRel;
		addElement(buttonClose, EventProperties.MOUSE);
		addElement(label1, 0);
		addElement(label2, 0);
		addElement(label3, 0);
		addElement(label4, 0);
		addElement(label5, 0);
		addElement(label6, 0);
		addElement(label7, 0);
	}
	private void buttonClose_onMouseLClickRel(Event ev) {
		close();
		
	}
	
}