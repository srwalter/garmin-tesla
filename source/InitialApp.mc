using Toybox.Application as App;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;

(:background)
class QuickTesla extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getServiceDelegate(){
        return [ new MyServiceDelegate() ];
    }

    function onBackgroundData(data) {
        Application.getApp().setProperty("vehicle_name", data["time"]);
        System.println("OBD: " + data["time"]);
        Ui.requestUpdate();
    }  

    (:glance)
    function getGlanceView() {
        return [ new GlanceView() ];
    }

    function getInitialView() {

        if(Background.getTemporalEventRegisteredTime() != null) {
            Background.registerForTemporalEvent(new Time.Duration(60*5));
        }

        if (!System.getDeviceSettings().phoneConnected) {
            return [ new OfflineView() ];
        }

        var data = new TeslaData();
        var view = new MainView(data);

        return [ view, new MainDelegate(data, view.method(:onReceive)) ];
    }
}