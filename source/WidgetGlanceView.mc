using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

(:glance)
class WidgetGlanceView extends Ui.GlanceView {
	
  function initialize() {
    GlanceView.initialize();
  }
    
  function onUpdate(dc) {
    var vehicle_name = Application.getApp().getProperty("vehicle_name");
    vehicle_name = (vehicle_name == null) ? Ui.loadResource(Rez.Strings.vehicle) : vehicle_name;
    var wake = Ui.loadResource(Rez.Strings.wake);

    dc.setColor(Gfx.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      0,
      dc.getHeight() / 2,
      Graphics.FONT_SMALL,
      wake + vehicle_name,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}