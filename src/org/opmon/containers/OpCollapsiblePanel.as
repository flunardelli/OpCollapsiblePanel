package org.opmon.containers
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.FlexVersion;
	import mx.core.ScrollPolicy;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.effects.Resize;
	import mx.events.EffectEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
	use namespace mx_internal;
	
	/**
	 *  Dispatched when the user collapses the panel.
	 *
	 *  @eventType minimize
	 */
	[Event(name="minimize", type="flash.events.Event")]
	
	/**
	 *  Dispatched when the user expands the panel.
	 *
	 *  @eventType restore
	 */
	[Event(name="restore", type="flash.events.Event")]
	
	/**
	 *  The collapse button disabled skin.
	 *
	 *  @default CollapseButtonDisabled
	 */
	[Style(name="collapseButtonDisabledSkin", type="Class", inherit="no")]
	
	/**
	 *  The collapse button down skin.
	 *
	 *  @default CollapseButtonDown
	 */
	[Style(name="collapseButtonDownSkin", type="Class", inherit="no")]
	
	/**
	 *  The collapse button over skin.
	 *
	 *  @default CollapseButtonOver
	 */
	[Style(name="collapseButtonOverSkin", type="Class", inherit="no")]
	
	/**
	 *  The collapse button up skin.
	 *
	 *  @default CollapseButtonUp
	 */
	[Style(name="collapseButtonUpSkin", type="Class", inherit="no")]
	
	/**
	 *  The collapse button default skin.
	 *
	 *  @default null
	 */
	[Style(name="collapseButtonSkin", type="Class", inherit="no", states="up, over, down, disabled")]
	
	/**
	 *  The collapse effect duration.
	 *
	 *  @default 250
	 */
	[Style(name="collapseDuration", type="Number", inherit="no")]
	
	/**
	 *  The collapse orientation.
	 *
	 *  @default left
	 */
	[Style(name="collapseOrientation", type="String", inherit="no", enumeration="top, bottom, right, left" )]
	
	/**
	 *  Bar size
	 *
	 *  @default left
	 */
	//[Style(name="collapsedBarSize", type="Number", inherit="no")]
		
	
	public class OpCollapsiblePanel extends Panel
	{
		
		/**
		 * @private
		 * Logger for this class.
		 */
		private static var logger:ILogger = Log.getLogger("org.opmon.containers.OpCollapsiblePanel");
		
		private static var classConstructed:Boolean = constructClass();
		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonDisabled")] 
		private static var collapseButtonDisabledSkin:Class;
		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonDownRight")] 
		private static var collapseButtonDownRightSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonOverRight")] 
		private static var collapseButtonOverRightSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonUpRight")]
		private static var collapseButtonUpRightSkin:Class;
		
		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonDownLeft")] 
		private static var collapseButtonDownLeftSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonOverLeft")] 
		private static var collapseButtonOverLeftSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonUpLeft")]
		private static var collapseButtonUpLeftSkin:Class;
		
		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonDownTop")] 
		private static var collapseButtonDownTopSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonOverTop")] 
		private static var collapseButtonOverTopSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonUpTop")]
		private static var collapseButtonUpTopSkin:Class;
		
		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonDownBottom")] 
		private static var collapseButtonDownBottomSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonOverBottom")] 
		private static var collapseButtonOverBottomSkin:Class;		
		[Embed(source="/assets/OpCollapsiblePanel/Assets.swf", symbol="CollapseButtonUpBottom")]
		private static var collapseButtonUpBottomSkin:Class;
		
		
		private var expandedWidth:Number;
		private var originalHScrollPolicy:String;
		
		private var styleRight:CSSStyleDeclaration;
		private var styleBottom:CSSStyleDeclaration;
		private var styleLeft:CSSStyleDeclaration;
		private var styleTop:CSSStyleDeclaration;
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		private static function constructClass() : Boolean
		{
			var styleDecl:CSSStyleDeclaration;
			if (!StyleManager.getStyleDeclaration("OpCollapsiblePanel"))
			{
				styleDecl = new CSSStyleDeclaration();
				styleDecl.defaultFactory = function () : void
				{
					this.collapseButtonUpSkin = collapseButtonUpLeftSkin;
					this.collapseButtonDownSkin = collapseButtonDownLeftSkin;
					this.collapseButtonOverSkin = collapseButtonOverLeftSkin;
					this.collapseButtonDisabledSkin = collapseButtonDisabledSkin;
					this.collapseDuration = 250;
					this.collapseOrientation = "left";
					this.collapsedBarSize = 15;
					return;
				};
				StyleManager.setStyleDeclaration("OpCollapsiblePanel", styleDecl, true);
			}
			return true;
		}// end function
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Internal component: Collapse Button.
		 */
		private var collapseButton:Button;
		
		/**
		 * @private
		 * Height of the component before collapse.
		 */
		private var expandedHeight:Number;
		
		/**
		 * @private
		 * The transition effect from collapsed to expanded and back.
		 */
		private var tween:Resize = new Resize(this);	 
		
		/**
		 * @private
		 * The original verticalScrollPolicy.
		 */
		private var originalVScrollPolicy:String;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function OpCollapsiblePanel()
		{
			super();
			
			tween.addEventListener(EffectEvent.EFFECT_END, tween_effectEndHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  collapseButtonStyleFilters
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the collapseButtonStyleFilters property.
		 */
		private static var _collapseButtonLeftStyleFilters:Object = 
			{
				"collapseButtonUpSkin" : "collapseButtonUpLeftSkin", 
				"collapseButtonOverSkin" : "collapseButtonOverLeftSkin",
				"collapseButtonDownSkin" : "collapseButtonDownLeftSkin",
				"collapseButtonDisabledSkin" : "collapseButtonDisabledSkin",
				"collapseButtonSkin" : "collapseButtonSkin",
				"repeatDelay" : "repeatDelay",
				"repeatInterval" : "repeatInterval"
			};
		
		/**
		 *  The set of styles to pass from the Panel to the collapse button.
		 *  @see mx.styles.StyleProxy
		 */
		protected function get collapseButtonStyleFilters():Object
		{
			
			return _collapseButtonLeftStyleFilters;
			
		}
		
		//----------------------------------
		//  collapsed
		//----------------------------------
		
		/**
		 * @private
		 * Storage for the collapsed property.
		 */
		private var _collapsed:Boolean = false;
		
		/**
		 * @private
		 * Dirty flag for the collapse property.
		 */
		private var collapsedChanged:Boolean = false;
		
		/**
		 * If <code>true</code>, the component is in its minimized state.
		 */
		public function get collapsed():Boolean
		{
			return _collapsed;
		}
		
		/**
		 * @private
		 */
		public function set collapsed(value:Boolean):void
		{
			if(_collapsed == value)
				return;
			
			_collapsed = value;
			collapsedChanged = true;
			
			invalidateSize();
			invalidateDisplayList();		
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		
		override protected function createChildren() : void
		{
			
			if (!closeButton){
				closeButton = new Button();
			}
			
			super.createChildren();
			
			if (titleBar){
				//titleBar.doubleClickEnabled = true;
				//titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, titleBar_doubleClickHandler);
			}
			
			styleRight = new CSSStyleDeclaration();
			styleRight.defaultFactory = function () : void {
				this.collapseButtonUpSkin = collapseButtonUpRightSkin;
				this.collapseButtonDownSkin = collapseButtonDownRightSkin;
				this.collapseButtonOverSkin = collapseButtonOverRightSkin;
				this.collapseButtonDisabledSkin = collapseButtonDisabledSkin;
				this.collapseDuration = 250;
				this.verticalOrientation = "right";
				this.collapsedBarSize = 15;						
				return;
			};
			styleBottom = new CSSStyleDeclaration();
			styleBottom.defaultFactory = function () : void {
				this.collapseButtonUpSkin = collapseButtonUpBottomSkin;
				this.collapseButtonDownSkin = collapseButtonDownBottomSkin;
				this.collapseButtonOverSkin = collapseButtonOverBottomSkin;
				this.collapseButtonDisabledSkin = collapseButtonDisabledSkin;
				this.collapseDuration = 250;
				this.verticalOrientation = "bottom";
				this.collapsedBarSize = 30;
				return;
			};
			
			styleLeft = new CSSStyleDeclaration();
			styleLeft.defaultFactory = function () : void {
				this.collapseButtonUpSkin = collapseButtonUpLeftSkin;
				this.collapseButtonDownSkin = collapseButtonDownLeftSkin;
				this.collapseButtonOverSkin = collapseButtonOverLeftSkin;
				this.collapseButtonDisabledSkin = collapseButtonDisabledSkin;
				this.collapseDuration = 250;
				this.verticalOrientation = "left";
				this.collapsedBarSize = 30;
				return;
			};
			
			styleTop = new CSSStyleDeclaration();
			styleTop.defaultFactory = function () : void {
				this.collapseButtonUpSkin = collapseButtonUpTopSkin;
				this.collapseButtonDownSkin = collapseButtonDownTopSkin;
				this.collapseButtonOverSkin = collapseButtonOverTopSkin;
				this.collapseButtonDisabledSkin = collapseButtonDisabledSkin;
				this.collapseDuration = 250;
				this.verticalOrientation = "top";
				this.collapsedBarSize = 30;
				return;
			};
			if (!collapseButton) {
				collapseButton = new Button();
				
				if (getStyle("collapseOrientation") == "right") {
					
					collapseButton.styleName = styleRight;
				}
				if (getStyle("collapseOrientation") == "bottom"){
					
					collapseButton.styleName = styleBottom;
				} else if (getStyle("collapseOrientation") == "left") {
					//collapseButton.styleName = new StyleProxy(this, collapseButtonStyleFilters);					
					collapseButton.styleName = styleLeft;
				}
				
				collapseButton.upSkinName = "collapseButtonUpSkin";
				collapseButton.overSkinName = "collapseButtonOverSkin";
				collapseButton.downSkinName = "collapseButtonDownSkin";
				collapseButton.disabledSkinName = "collapseButtonDisabledSkin";
				collapseButton.skinName = "collapseButtonSkin";
				collapseButton.explicitHeight = 15;
				collapseButton.explicitWidth = 15;
				collapseButton.focusEnabled = false;
				collapseButton.enabled = enabled;
				collapseButton.addEventListener(MouseEvent.CLICK, collapseButton_clickHandler);
				titleBar.addChild(collapseButton);
				collapseButton.owner = this;
			}
			return;
		}// end function
		
		/**
		 * @private
		 */
		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutChrome(unscaledWidth, unscaledHeight);
			
			var em:EdgeMetrics = EdgeMetrics.EMPTY;
			var bt:Number = getStyle("borderThickness"); 
			if (getQualifiedClassName(this.border) == "mx.skins.halo::PanelSkin" && getStyle("borderStyle") != "default" && bt) 
			{
				em = new EdgeMetrics(bt, bt, bt, bt);
			}
			
			var bm:EdgeMetrics =
				FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0 ?
				borderMetrics :
				em;      
			
			var headerHeight:int = getHeaderHeight();
			var x:Number = bm.left;
			var y:Number = bm.top;
			
			if(collapseButton)
			{
				collapseButton.setActualSize(collapseButton.getExplicitOrMeasuredWidth(), collapseButton.getExplicitOrMeasuredHeight());
				
				collapseButton.move(x + 10, (headerHeight - collapseButton.getExplicitOrMeasuredHeight()) / 2);
				
				var h:Number;
				var offset:Number;
				var rightOffset:Number = 10;
				
				if (getStyle("collapseOrientation") == "right") {
					collapseButton.move(2, (headerHeight - collapseButton.getExplicitOrMeasuredHeight()) / 2);
				} else if (getStyle("collapseOrientation") == "bottom") {
					collapseButton.move(width - 5 - collapseButton.getExplicitOrMeasuredWidth(), (headerHeight - collapseButton.getExplicitOrMeasuredHeight()) / 2);
				} else {
					collapseButton.move(width - 2 - collapseButton.getExplicitOrMeasuredWidth(), (headerHeight - collapseButton.getExplicitOrMeasuredHeight()) / 2);
				}
				
				if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0){
					h = titleTextField.nonZeroTextHeight;
				} else { 
					h = titleTextField.getUITextFormat().measureText(titleTextField.text).height;
				}
				offset = (headerHeight - h) / 2;
				
				var titleX:Number = x + 10 + collapseButton.getExplicitOrMeasuredWidth();
				titleTextField.move(titleX, offset - 1);
				
				var borderWidth:Number = bm.left + bm.right; 
				var statusX:Number = unscaledWidth - rightOffset - 4 - borderWidth - statusTextField.textWidth;
				statusTextField.move(statusX, offset - 1);
				statusTextField.setActualSize(statusTextField.textWidth + 8, statusTextField.textHeight + UITextField.TEXT_HEIGHT_PADDING);
				
				var minX:Number = titleTextField.x + titleTextField.textWidth + 8;
				if (statusTextField.x < minX) {
					statusTextField.width = Math.max(statusTextField.width - (minX - statusTextField.x), 0);
					statusTextField.x = minX;
				}
			}		
		}
		
		/**
		 * @private
		 */		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (collapsedChanged)
			{
				collapsedChanged = false;
				if (_collapsed) {
					originalVScrollPolicy = verticalScrollPolicy;
					expandedHeight = unscaledHeight;
					originalHScrollPolicy = horizontalScrollPolicy;
					expandedWidth = unscaledWidth;
					verticalScrollPolicy = ScrollPolicy.OFF;
					horizontalScrollPolicy = ScrollPolicy.OFF;
					if (getStyle("collapseOrientation") == "bottom") {
						tween.heightTo = getHeaderHeight();
						collapseButton.styleName = styleLeft;
					} else {
						tween.widthTo = getStyle("collapsedBarSize");
					}
					if (getStyle("collapseOrientation") == "right") {
						tween.reverse();
						collapseButton.styleName = styleBottom;
					}
					if (getStyle("collapseOrientation") == "top") {
						collapseButton.styleName = styleLeft;
					}
					if (getStyle("collapseOrientation") == "left") {
						collapseButton.styleName = styleBottom;
					}
					this.addEventListener(MouseEvent.CLICK, collapseButton_clickHandler);
				}
				else {
					if (getStyle("collapseOrientation") == "bottom") {
						tween.heightTo = expandedHeight;
						collapseButton.styleName = styleBottom;
					} else {
						tween.widthTo = expandedWidth;
					}
					
					if (getStyle("collapseOrientation") == "left") {
						collapseButton.styleName = styleLeft;
					}					
					if (getStyle("collapseOrientation") == "right") {
						tween.reverse();						
						collapseButton.styleName = styleRight;
					}
					if (getStyle("collapseOrientation") == "top") {
						collapseButton.styleName = styleTop;
					}					
					this.removeEventListener(MouseEvent.CLICK, collapseButton_clickHandler);
				}
				if (tween.isPlaying) {
					tween.stop();
				}
				if (getStyle("collapseDuration")) {
					tween.duration = getStyle("collapseDuration") as Number;
				}
				tween.hideChildrenTargets = [this];
				tween.play();
			}
			return;
		}// end function
		
		//--------------------------------------------------------------------------
		//
		//  Asset event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Handles user click on the collapse button.
		 */
		private function collapseButton_clickHandler(event:MouseEvent):void
		{
			collapsed = !_collapsed;
			
			if(_collapsed){
				dispatchEvent(new Event("minimize"));
			} else {
				dispatchEvent(new Event("restore"));
			}
			event.stopImmediatePropagation();
		}
		
		/**
		 * @private
		 * Handles user double-click on the header area.
		 */
		private function titleBar_doubleClickHandler(event:MouseEvent):void
		{
			if(!enabled)
				return;
			
			collapsed = !_collapsed;
			
			if(_collapsed)
				dispatchEvent(new Event("minimize"));
			else
				dispatchEvent(new Event("restore"));
		}
		
		private function tween_effectEndHandler(event:EffectEvent):void
		{
			verticalScrollPolicy = originalVScrollPolicy;
			horizontalScrollPolicy = originalHScrollPolicy;
		}
	}
}