module PixelPerfectEngine.concrete.elements.radiobutton;

public import PixelPerfectEngine.concrete.elements.base;
import collections.linkedlist;

/**
 * Implements a single radio button.
 * Needs to be grouped to used.
 * Equality is checked by comparing `source`, so give each RadioButton a different source value.
 */
public class RadioButton : WindowElement, IRadioButton, ISmallButton {
	protected IRadioButtonGroup		group;		///The group which this object belongs to.
	//protected bool					_isLatched;		///The state of the RadioButton
	public string					iconLatched = "radioButtonB";		///Sets the icon for latched positions
	public string					iconUnlatched = "radioButtonA";	///Sets the icon for unlatched positions
	public this(Text text, string source, Box coordinates, IRadioButtonGroup group = null) {
		position = coordinates;
		this.text = text;
		this.source = source;
		output = new BitmapDrawer(position.width, position.height);
		if (group) group.add(this);
	}
	///Ditto
	public this(dstring text, string source, Box coordinates, IRadioButtonGroup group = null) {
		this(new Text(text, getAvailableStyleSheet().getChrFormatting("checkBox")), source, coordinates, group);
	}
	///Ditto
	public this(string iconLatched, string iconUnlatched, string source, Box coordinates, IRadioButtonGroup group = null) {
		position = coordinates;
		this.iconLatched = iconLatched;
		this.iconUnlatched = iconUnlatched;
		this.source = source;
		output = new BitmapDrawer(position.width, position.height);
		group.add(this);
	}
	override public void draw() {
		parent.clearArea(position);
		StyleSheet ss = getStyleSheet();
		Bitmap8Bit icon = isChecked ? ss.getImage(iconLatched) : ss.getImage(iconUnlatched);
		parent.bitBLT(Coordinate.cornerUL, icon);
		if (text) {
			Box textPos = position;
			textPos.left += icon.width + getAvailableStyleSheet.drawParameters["TextSpacingSides"];
			parent.drawTextSL(textPos, text, Point.init);
		}

		if (isFocused) {
			const int textPadding = ss.drawParameters["horizTextPadding"];
			parent.drawBoxPattern(position - textPadding, ss.pattern["blackDottedLine"]);
		}

		if (state == ElementState.Disabled) {
			parent.bitBLTPattern(position, ss.getImage("ElementDisabledPtrn"));
		}
		/+if(text) {
			const int textPadding = getAvailableStyleSheet.drawParameters["TextSpacingSides"];
			const Coordinate textPos = Coordinate(textPadding +	getAvailableStyleSheet().getImage(iconUnlatched).width,
					(position.height / 2) - (text.font.size / 2), position.width, position.height - textPadding);
			output.drawSingleLineText(textPos, text);
		}
		/+output.drawColorText(getAvailableStyleSheet().getImage("checkBoxA").width, 0, text,
				getAvailableStyleSheet().getFontset("default"), getAvailableStyleSheet().getColor("normaltext"), 0);+/
		if(_isLatched) {
			output.insertBitmap(0, 0, getAvailableStyleSheet().getImage(iconLatched));
		} else {
			output.insertBitmap(0, 0, getAvailableStyleSheet().getImage(iconUnlatched));
		}
		elementContainer.drawUpdate(this);
		if(onDraw !is null) {
			onDraw();
		}+/
	}

	public override void passMCE(MouseEventCommons mec, MouseClickEvent mce) {
		if (mce.button == MouseButton.Left, mce.state == ButtonState.Pressed) group.latch(this);
		super.passMCE(mec, mce);
	}
	/**
	 * If the radio button is pressed, then it sets to unpressed. Does nothing otherwise.
	 */
	public void latchOff() @trusted {
		if (isChecked) {
			flags &= ~IS_CHECKED;
			draw();	
		}
	}
	/**
	 * Sets the radio button into its pressed state.
	 */
	public void latchOn() @trusted {
		if (!ischecked) {
			flags |= IS_CHECKED;
			draw();
		}
	}
	
	/**
	 * Sets the group of the radio button.
	 */
	public void setGroup(IRadioButtonGroup group) @safe @property {
		this.group = group;
	}
	public bool equals(IRadioButton rhs) @safe pure @nogc nothrow const {
		WindowElement we = cast(WindowElement)rhs;
		return source == we.source;
	}
	public string value() @property @safe @nogc pure nothrow const {
		return source;
	}
	public bool isSmallButtonHeight(int height) {
		if (text) return false;
		else if (position.width == height && position.height == height) return true;
		else return false;
	}
}

/**
 * Radio Button Group implementation.
 * Can send events via it's delegates.
 */
public class RadioButtonGroup : IRadioButtonGroup {
	alias RadioButtonSet = LinkedList!(IRadioButton, false, "a.equals(b)");
	protected RadioButtonSet radioButtons;
	protected IRadioButton latchedButton;
	protected size_t _value;
	///Empty ctor
	public this() @safe pure nothrow @nogc {
		
	}
	/**
	 * Creates a new group with some starting elements from a compatible range.
	 */
	public this(R)(R range) @safe {
		foreach (key; range) {
			radioButtons.put(key);
		}
	}
	/**
	 * Adds a new RadioButton to the group.
	 */
	public void add(IRadioButton rg) @safe {
		radioButtons.put(rg);
		rg.setGroup(this);
	}
	/**
	 * Removes the given RadioButton from the group.
	 */
	public void remove(IRadioButton rg) @safe {
		radioButtons.removeByElem(rg);
		rg.setGroup(null);
	}
	/**
	 * Latches the group.
	 */
	public void latch(IRadioButton sender) @safe {
		latchedButton = sender;
		foreach(elem; radioButtons) {
			elem.latchOff;
		}
		sender.latchOn;
	}
	/**
	 * Returns the value of this group.
	 */
	public @property string value() const @nogc @safe pure nothrow {
		if(latchedButton !is null) return latchedButton.value;
		else return null;
	}
	
}