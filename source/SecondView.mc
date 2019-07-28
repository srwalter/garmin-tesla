using Toybox.WatchUi as Ui;

class SecondView extends Ui.View {
    hidden var _display;
    var _data;

    function initialize(data) {
        View.initialize();
        _data = data;
        _display = "";
    }

    //! Load your resources here
    function onLayout(dc) {
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        var center_x = dc.getWidth()/2;
        var center_y = dc.getHeight()/2;
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.clear();
        if (_display != null) {
            dc.drawText(center_x, center_y, Graphics.FONT_MEDIUM, _display, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            if (_data._vehicle != null) {
                dc.drawText(center_x, 40, Graphics.FONT_SMALL, _data._vehicle.get("vehicle_name"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            var radius;
            if (center_x < center_y) {
                radius = center_x-5;
            } else {
                radius = center_y-5;
            }
            dc.setPenWidth(5);
            dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 180, 0);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            if (_data._charge != null) {
                var charge = _data._charge.get("battery_level");
                var requested_charge = _data._charge.get("charge_limit_soc");
                dc.drawText(60, 110, Graphics.FONT_MEDIUM, "Charge: " + charge.toString() + "%", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                var angle = (180 - (charge * 180 / 100)) % 360;
                System.println(angle.toString());
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 180, angle);
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                angle = 180 - (requested_charge * 180 / 100);
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, angle-1, angle-4);
                System.println("Requested " + requested_charge.toString());
                System.println("Angle " + angle.toString());
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.drawText(60, 110, Graphics.FONT_MEDIUM, "Charge: ", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            if (_data._climate != null) {
                var temp = _data._climate.get("inside_temp").toNumber().toString();
                dc.drawText(60, 140, Graphics.FONT_MEDIUM, "Cabin: " + temp + " C", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                var on = _data._climate.get("is_climate_on") ? "On" : "Off";
                dc.drawText(60, 170, Graphics.FONT_MEDIUM, "Climate: " + on, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.drawText(60, 140, Graphics.FONT_MEDIUM, "Cabin: ", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(60, 170, Graphics.FONT_MEDIUM, "Climate: ", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() - 20, 60, Graphics.FONT_TINY, "Climate On", Graphics.TEXT_JUSTIFY_RIGHT);
            dc.drawText(15, center_y, Graphics.FONT_TINY, "Frunk", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(20, 150, Graphics.FONT_TINY, "Horn", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    function onReceive(args) {
        _display = args;
        WatchUi.requestUpdate();
    }
}
