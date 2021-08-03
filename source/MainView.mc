using Toybox.WatchUi as Ui;
using Toybox.System;

class MainView extends Ui.View {
    hidden var _display;
    var _data;

    // Initial load - show the 'requesting data' string, make sure we don't process touches
    function initialize(data) {
        View.initialize();
        _data = data;
        _data._ready = false;
        _display = Ui.loadResource(Rez.Strings.label_requesting_data);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ImageLayout(dc));
    }

    function onReceive(args) {
        _display = args;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        // Set up all our variables for drawing things in the right place!
        var width = dc.getWidth();
        var height = dc.getHeight();
        var extra = (width/7+width/28) * ((width.toFloat()/height.toFloat())-1);
        var image_x_left = (width/7+width/28+extra).toNumber();
        var image_y_top = (height/7+height/21).toNumber();
        var image_x_right = (width/7*4-width/28+extra).toNumber();
        var image_y_bottom = (height/7*4-height/21).toNumber();
        var center_x = dc.getWidth()/2;
        var center_y = dc.getHeight()/2;
        
        // Load our custom font if it's there, generally only for high res, high mem devices
        var font_montserrat;
        if (Rez.Fonts has :montserrat) {
            font_montserrat=Ui.loadResource(Rez.Fonts.montserrat);
        } else {
            font_montserrat=Graphics.FONT_SMALL;
        }

        // Redraw the layout and wipe the canvas              
        if (_display != null) 
        {
            // We're showing a message, so set 'ready' false to prevent touches
            _data._ready = false;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.clear();
            dc.drawText(center_x, center_y, font_montserrat, _display, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {           
            // Showing the main layouts, so we can process touches now
            _data._ready = true;

            // We're going to use the image layout by default if it's a touchscreen, also check the option setting to allow toggling
            var is_touchscreen = System.getDeviceSettings().isTouchScreen;
            var use_image_layout = Application.getApp().getProperty("image_view") == null ? System.getDeviceSettings().isTouchScreen : Application.getApp().getProperty("image_view");
            Application.getApp().setProperty("image_view", use_image_layout);

            if (use_image_layout)
            {
                // We're loading the image layout
                setLayout(Rez.Layouts.ImageLayout(dc));
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.clear();
                View.onUpdate(dc);
            
                // Draw the initial icons (in white) in case we don't have vehicle data
                dc.drawBitmap(image_x_left,image_y_top,Ui.loadResource(Rez.Drawables.frunk_icon_white));
                dc.drawBitmap(image_x_right,image_y_top,Ui.loadResource(Rez.Drawables.climate_on_icon_white));
                dc.drawBitmap(image_x_left,image_y_bottom,Ui.loadResource(Rez.Drawables.locked_icon_white));
                dc.drawBitmap(image_x_right,image_y_bottom,Ui.loadResource(is_touchscreen? Rez.Drawables.settings_icon : Rez.Drawables.back_icon));
            }
            else
            {
                // We're loading the text based layout
                setLayout(Rez.Layouts.TextLayout(dc));
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.clear();
                View.onUpdate(dc);
            }

            // Draw the grey arc in an appropriate size for the display
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            var radius;
            if (center_x < center_y) {
                radius = center_x-3;
            } else {
                radius = center_y-3;
            }

            // Dynamic pen width based on screen size
            dc.setPenWidth(((dc.getWidth()/33)).toNumber());
            dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 225, 315);

            // If we have the vehicle data back from the API, this is where the good stuff happens
            if (_data._vehicle_data != null) {
                // Retrieve and display the vehicle name
                var name_drawable = View.findDrawableById("name");
                var vehicle_name = _data._vehicle_data.get("display_name");
                Application.getApp().setProperty("vehicle_name", vehicle_name);
                name_drawable.setText(vehicle_name);
                name_drawable.draw(dc);

                // Grab the data we're going to use around charge and climate
                var battery_level = _data._vehicle_data.get("charge_state").get("battery_level");
                var charge_limit = _data._vehicle_data.get("charge_state").get("charge_limit_soc");
                var charging_state = _data._vehicle_data.get("charge_state").get("charging_state");
                var inside_temp = _data._vehicle_data.get("climate_state").get("inside_temp").toNumber();
                var inside_temp_local = Application.getApp().getProperty("imperial") ? ((inside_temp*9/5) + 32) + "°F" : inside_temp + "°C";
                var driver_temp = _data._vehicle_data.get("climate_state").get("driver_temp_setting");
                
                // Draw the charge status
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                var charge_angle = 225 - (battery_level * 270 / 100);
                charge_angle = charge_angle < 0 ? 360 + charge_angle : charge_angle;
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, 225, charge_angle);

                // Draw the charge limit indicator
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                var limit_angle = 225 - (charge_limit * 270 / 100);
                var limit_start_angle = limit_angle + 2;
                limit_start_angle = limit_start_angle < 0 ? 360 + limit_start_angle : limit_start_angle;
                var limit_end_angle = limit_angle - 2;
                limit_end_angle = limit_end_angle < 0 ? 360 + limit_end_angle : limit_end_angle;
                dc.drawArc(center_x, center_y, radius, Graphics.ARC_CLOCKWISE, limit_start_angle, limit_end_angle);

                if (use_image_layout)
                {
                    // We're using image layout, so update the lock state indicator
                    dc.drawBitmap(image_x_left.toNumber(),image_y_bottom,(_data._vehicle_data.get("vehicle_state").get("locked") ? Ui.loadResource(Rez.Drawables.locked_icon) : Ui.loadResource(Rez.Drawables.unlocked_icon)));

                    // Update the text at the bottom of the screen with charge and temperature
                    var status_drawable = View.findDrawableById("status");
                    status_drawable.setText(battery_level + (charging_state.equals("Charging") ? "%+ / " : "% / ") + inside_temp_local);
                    status_drawable.draw(dc);

                    // Update the climate state indicator, note we have blue or red icons depending on heating or cooling
                    var climate_state = _data._vehicle_data.get("climate_state").get("is_climate_on");          
                    if (climate_state == false)
                    {
                        dc.drawBitmap(image_x_right,image_y_top.toNumber(), Ui.loadResource(Rez.Drawables.climate_off_icon));
                    }
                    else if (climate_state == true && driver_temp > inside_temp)
                    {
                        dc.drawBitmap(image_x_right,image_y_top, Ui.loadResource(Rez.Drawables.climate_on_icon_blue));
                    }
                    else
                    {
                        dc.drawBitmap(image_x_right,image_y_top, Ui.loadResource(Rez.Drawables.climate_on_icon_red));
                    }
                }
                else
                {           
                    // Text layout, so update the lock status text   
                    var status_drawable = View.findDrawableById("status");
                    if (_data._vehicle_data.get("vehicle_state").get("locked")) {
                        status_drawable.setColor(Graphics.COLOR_GREEN);
                        status_drawable.setText(Rez.Strings.label_locked);
                    } else {
                        status_drawable.setColor(Graphics.COLOR_RED);
                        status_drawable.setText(Rez.Strings.label_unlocked);
                    }              
                    status_drawable.draw(dc);
                    
                    // Update the temperature text
                    var inside_temp_drawable = View.findDrawableById("inside_temp");
                    inside_temp_drawable.setText(Ui.loadResource(Rez.Strings.label_cabin) + inside_temp_local.toString());

                    // Update the climate state text
                    var climate_state_drawable = View.findDrawableById("climate_state");
                    var climate_state = Ui.loadResource(Rez.Strings.label_climate) + (_data._vehicle_data.get("climate_state").get("is_climate_on") ? Ui.loadResource(Rez.Strings.label_on) : Ui.loadResource(Rez.Strings.label_off));
                    climate_state_drawable.setText(climate_state);

                    // Update the battery level text
                    var battery_level_drawable = View.findDrawableById("battery_level");  
                    battery_level_drawable.setColor((charging_state.equals("Charging")) ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
                    battery_level_drawable.setText(Ui.loadResource(Rez.Strings.label_charge) + battery_level.toString() + "%");
                    
                    // Do the draws
                    inside_temp_drawable.draw(dc);
                    climate_state_drawable.draw(dc);
                    battery_level_drawable.draw(dc);
                }               
            }
        }
    }
}
