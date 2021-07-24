using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

(:glance)
class GlanceView extends Ui.GlanceView {
	
  function initialize() {
    GlanceView.initialize();
  }

  function onUpdate(dc) {
    // Retrieve the name of the vehicle if we have it, or the generic string otherwise
    var vehicle_name = Application.getApp().getProperty("vehicle_name");
    vehicle_name = (vehicle_name == null) ? Ui.loadResource(Rez.Strings.vehicle) : vehicle_name;
    var wake = Ui.loadResource(Rez.Strings.wake);

    // Draw the two rows of text on the glance widget
    dc.setColor(Gfx.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      0,
      (dc.getHeight() / 8) * 2,
      Graphics.FONT_TINY,
      "TESLA",
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.drawText(
      0,
      (dc.getHeight() / 8) * 6,
      Graphics.FONT_TINY,
      vehicle_name,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}