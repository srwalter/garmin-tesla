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
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.clear();
        if (_display != null) {
            dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, _display, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            if (_data._charge != null) {
                var charge = _data._charge.get("battery_level").toString();
                dc.drawText(dc.getWidth()/2, 40, Graphics.FONT_MEDIUM, "Charge: " + charge, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.drawText(dc.getWidth()/2, 40, Graphics.FONT_MEDIUM, "Charge: ", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            if (_data._climate != null) {
                var temp = _data._climate.get("inside_temp").toNumber().toString();
                dc.drawText(dc.getWidth()/2, 80, Graphics.FONT_MEDIUM, "Temp: " + temp, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                var on = _data._climate.get("is_climate_on") ? "On" : "Off";
                dc.drawText(dc.getWidth()/2, 120, Graphics.FONT_MEDIUM, "Climate: " + on, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.drawText(dc.getWidth()/2, 80, Graphics.FONT_MEDIUM, "Temp: ", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(dc.getWidth()/2, 120, Graphics.FONT_MEDIUM, "Climate: ", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
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
