using Toybox.WatchUi as Ui;
using Toybox.System;

class MainView extends Ui.View {
    hidden var _display;
    var _data;

    function initialize(data) {
        View.initialize();
        _data = data;
        _display = Ui.loadResource(Rez.Strings.label_requesting_data);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ImageLayout(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var center_x = dc.getWidth()/2;
        var center_y = dc.getHeight()/2;
        
        // Load our custom font if it's there
        var font_montserrat;
        if (Rez.Fonts has :montserrat) {
            font_montserrat=Ui.loadResource(Rez.Fonts.montserrat);
        } else {
            font_montserrat=Graphics.FONT_SMALL;
        }

        // Redraw the layout and wipe the canvas        
        
        if (_display != null) 
        {
            _data._ready = false;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();
            dc.drawText(center_x, center_y, font_montserrat, _display, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {           
            _data._ready = true;

            var is_touchscreen = System.getDeviceSettings().isTouchScreen;
            
            var use_image_layout = Application.getApp().getProperty("image_view") == null ? System.getDeviceSettings().isTouchScreen : Application.getApp().getProperty("image_view");
            Application.getApp().setProperty("image_view", use_image_layout);

            if (use_image_layout)
            {
                setLayout(Rez.Layouts.ImageLayout(dc));
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.clear();
                View.onUpdate(dc);

                dc.drawBitmap((width/7+width/28).toNumber(),(width/7+width/21).toNumber(),Ui.loadResource(Rez.Drawables.frunk_icon_white));
                dc.drawBitmap((width/7*4-width/28).toNumber(),(width/7+width/21).toNumber(),Ui.loadResource(Rez.Drawables.climate_on_icon_white));
                dc.drawBitmap((width/7+width/28).toNumber(),(width/7*4-width/21).toNumber(),Ui.loadResource(Rez.Drawables.locked_icon_white));
                dc.drawBitmap((width/7*4-width/28).toNumber(),(width/7*4-width/21).toNumber(),Ui.loadResource(is_touchscreen? Rez.Drawables.settings_icon : Rez.Drawables.back_icon));
            }
            else
            {
                setLayout(Rez.Layouts.TextLayout(dc));
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.clear();
                View.onUpdate(dc);
            }

            // Draw the grey arc
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            var radius;
            if (center_x < center_y) {
                radius = center_x-3;
            } else {
                radius = center_y-3;
            }

            dc.setPenWidth(((dc.getWidth()/33)).toNumber());
            dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 225, 315);

            if (_data._vehicle_data != null) {
                var name_drawable = View.findDrawableById("name");
                var vehicle_name = _data._vehicle_data.get("display_name");
                Application.getApp().setProperty("vehicle_name", vehicle_name);
                name_drawable.setText(vehicle_name);
                name_drawable.draw(dc);

                var battery_level = _data._vehicle_data.get("charge_state").get("battery_level");
                var charge_limit = _data._vehicle_data.get("charge_state").get("charge_limit_soc");
                var charging_state = _data._vehicle_data.get("charge_state").get("charging_state");
                var inside_temp = _data._vehicle_data.get("climate_state").get("inside_temp").toNumber();
                var inside_temp_local = Application.getApp().getProperty("imperial") ? inside_temp + "°F" : inside_temp + "°C";
                var driver_temp = _data._vehicle_data.get("climate_state").get("driver_temp_setting");
                
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                var angle = (225 - (battery_level * 270 / 100)) % 360;
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 225, angle.abs());

                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                angle = 225 - (charge_limit * 270 / 100);
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, angle.abs()+2, angle.abs()-2);

                if (use_image_layout)
                {
                    dc.drawBitmap((width/7+width/28).toNumber(),(width/7*4-width/21).toNumber(),(_data._vehicle_data.get("vehicle_state").get("locked") ? Ui.loadResource(Rez.Drawables.locked_icon) : Ui.loadResource(Rez.Drawables.unlocked_icon)));

                    var status_drawable = View.findDrawableById("status");
                    status_drawable.setText(battery_level + (charging_state ? "% / " : "+ / ") + inside_temp_local);
                    status_drawable.draw(dc);

                    var climate_state = _data._vehicle_data.get("climate_state").get("is_climate_on");
                               
                    if (climate_state == false)
                    {
                        dc.drawBitmap((width/7*4-width/28).toNumber(),(width/7+width/21).toNumber(), Ui.loadResource(Rez.Drawables.climate_off_icon));
                    }
                    else if (climate_state == true && driver_temp > inside_temp)
                    {
                        dc.drawBitmap((width/7*4-width/28).toNumber(),(width/7+width/21).toNumber(), Ui.loadResource(Rez.Drawables.climate_on_icon_blue));
                    }
                    else
                    {
                        dc.drawBitmap((width/7*4-width/28).toNumber(),(width/7+width/21).toNumber(), Ui.loadResource(Rez.Drawables.climate_on_icon_red));
                    }
                }
                else
                {              
                    var status_drawable = View.findDrawableById("status");
                    if (_data._vehicle_data.get("vehicle_state").get("locked")) {
                        status_drawable.setColor(Graphics.COLOR_GREEN);
                        status_drawable.setText(Rez.Strings.label_locked);
                    } else {
                        status_drawable.setColor(Graphics.COLOR_RED);
                        status_drawable.setText(Rez.Strings.label_unlocked);
                    }              
                    status_drawable.draw(dc);
                    
                    var inside_temp_drawable = View.findDrawableById("inside_temp");
                    inside_temp_drawable.setText(Ui.loadResource(Rez.Strings.label_cabin) + inside_temp_local.toString());

                    var climate_state_drawable = View.findDrawableById("climate_state");
                    var climate_state = Ui.loadResource(Rez.Strings.label_climate) + (_data._vehicle_data.get("climate_state").get("is_climate_on") ? Ui.loadResource(Rez.Strings.label_on) : Ui.loadResource(Rez.Strings.label_off));
                    climate_state_drawable.setText(climate_state);

                    var battery_level_drawable = View.findDrawableById("battery_level");  
                    battery_level_drawable.setColor((charging_state.equals("Charging")) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
                    battery_level_drawable.setText(Ui.loadResource(Rez.Strings.label_charge) + battery_level.toString() + "%");
                    battery_level_drawable.draw(dc);
                    
                    inside_temp_drawable.draw(dc);
                    climate_state_drawable.draw(dc);
                }               
            }
        }
    }

    function onHide() {
    }

    function onReceive(args) {
        _display = args;
        WatchUi.requestUpdate();
    }
}
