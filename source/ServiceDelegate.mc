using Toybox.Application as App;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;

(:background)
class MyServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        System.ServiceDelegate.initialize();
        System.println("Init");
    }

    function onTemporalEvent() {
        var data = Background.getBackgroundData();
        if (data == null) {
			data = {};
		}
        data.put("time", System.getClockTime().hour.format("%d")+":"+System.getClockTime().min.format("%02d"));
        Background.exit(data);
    }   

}