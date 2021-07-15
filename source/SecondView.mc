using Toybox.WatchUi as Ui;

class SecondView extends Ui.View {
    hidden var _display;
    var _data;

    function initialize(data) {
        View.initialize();
        _data = data;
        _display = Ui.loadResource(Rez.Strings.label_requesting_data);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.TeslaLayout(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var center_x = dc.getWidth()/2;
        var center_y = dc.getHeight()/2;
        
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (_display != null) {
            dc.drawText(center_x, center_y, Graphics.FONT_MEDIUM, _display, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            View.onUpdate(dc);

            // Draw labels from the vehicle object if available
            if (_data._vehicle != null) {
                var name_drawable = View.findDrawableById("name");
                name_drawable.setText(_data._vehicle.get("vehicle_name"));
                name_drawable.draw(dc);

                var locked_drawable = View.findDrawableById("locked");
                if (_data._vehicle.get("locked")) {
                    locked_drawable.setColor(Graphics.COLOR_GREEN);
                    locked_drawable.setText(Rez.Strings.label_locked);
                } else {
                    locked_drawable.setColor(Graphics.COLOR_RED);
                    locked_drawable.setText(Rez.Strings.label_unlocked);
                }              
                locked_drawable.draw(dc);
            }

            // Draw the grey arc
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            var radius;
            if (center_x < center_y) {
                radius = center_x-5;
            } else {
                radius = center_y-5;
            }
            dc.setPenWidth(5);
            dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 225, 315);
            
            // Draw the charge limit marker, arc and set charge text if we have the data
            var battery_level_drawable = View.findDrawableById("battery_level");       
            if (_data._charge != null) {
                var battery_level = _data._charge.get("battery_level");
                var charge_limit = _data._charge.get("charge_limit_soc");
                var charging_state = _data._charge.get("charging_state");
                
                battery_level_drawable.setColor((charging_state.equals("Charging")) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
                battery_level_drawable.setText(Ui.loadResource(Rez.Strings.label_charge) + battery_level.toString() + "%");
                battery_level_drawable.draw(dc);

                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                var angle = (225 - (battery_level * 270 / 100)) % 360;
                System.println("Angle " + angle);
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 225, angle.abs());

                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                angle = 225 - (charge_limit * 270 / 100);
                System.println("Angle 2 " + angle);
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, angle.abs()-1, angle.abs()-4);
            }

            // Draw labels from the climate object if available
            var climate_state_drawable = View.findDrawableById("climate_state");
            var inside_temp_drawable = View.findDrawableById("inside_temp");

            if (_data._climate != null) {
                var inside_temp = _data._climate.get("inside_temp").toNumber();

                if (Application.getApp().getProperty("imperial")) {
                    inside_temp = (inside_temp * 9 / 5) + 32;
                    inside_temp_drawable.setText(Ui.loadResource(Rez.Strings.label_cabin) + inside_temp.toString() + "°F");
                } else {
                    inside_temp_drawable.setText(Ui.loadResource(Rez.Strings.label_cabin) + inside_temp.toString() + "°C");
                }

                var climate_state = Ui.loadResource(Rez.Strings.label_climate) + (_data._climate.get("is_climate_on") ? Ui.loadResource(Rez.Strings.label_on) : Ui.loadResource(Rez.Strings.label_off));
                climate_state_drawable.setText(climate_state);
            }
            else
            {
                //inside_temp_drawable.setText(Ui.loadResource(Rez.Strings.label_cabin) + "?");
                //climate_state_drawable.setText( Ui.loadResource(Rez.Strings.label_climate) + "?");
            }
            inside_temp_drawable.draw(dc);
            climate_state_drawable.draw(dc);
        }
    }

    function onHide() {
    }

    function onReceive(args) {
        _display = args;
        WatchUi.requestUpdate();
    }
}
