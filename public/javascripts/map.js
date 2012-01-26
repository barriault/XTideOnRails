var map;
var centerLatitude = 38.134557;
var centerLongitude = -95.537109;
var startZoom = 3;

//create an icon for the clusters
var iconCluster = new GIcon();
iconCluster.image = "/images/zoom_in.png";
iconCluster.shadow = "images/shadow-zoom_in.png";
iconCluster.iconSize = new GSize(16, 16);
iconCluster.shadowSize = new GSize(25, 16);
iconCluster.iconAnchor = new GPoint(8, 8);
iconCluster.infoWindowAnchor = new GPoint(8, 8);

//create an icon for the ref locations
var iconRef = new GIcon();
iconRef.image = "/images/flag_red.png";
iconRef.shadow = "images/shadow-flag.png";
iconRef.iconSize = new GSize(16, 16);
iconRef.shadowSize = new GSize(25, 16);
iconRef.iconAnchor = new GPoint(11, 16);
iconRef.infoWindowAnchor = new GPoint(8, 8);

//create an icon for the sub locations
var iconSub = new GIcon();
iconSub.image = "/images/flag_green.png";
iconSub.shadow = "images/shadow-flag.png";
iconSub.iconSize = new GSize(16, 16);
iconSub.shadowSize = new GSize(25, 16);
iconSub.iconAnchor = new GPoint(11, 16);
iconSub.infoWindowAnchor = new GPoint(8, 8);


function init() {
    map = new GMap2(document.getElementById("map_div"));
    map.addControl(new GLargeMapControl());
    map.addControl(new GMapTypeControl());
    map.setCenter(new GLatLng(centerLatitude, centerLongitude), startZoom);

    updateMarkers();

    GEvent.addListener(map,'zoomend',function() {
        updateMarkers();
    });
    GEvent.addListener(map,'moveend',function() {
        updateMarkers();
    });
}

function updateMarkers() {

    //remove the existing points
    map.clearOverlays();
    //create the boundary for the data to provide
    //initial filtering
    var bounds = map.getBounds();
    var southWest = bounds.getSouthWest();
    var northEast = bounds.getNorthEast();
    var url = '/map/clustered_locations?ne=' + northEast.toUrlValue() +
      '&sw=' + southWest.toUrlValue();

    //log the URL for testing
    // GLog.writeUrl(url);

    //retrieve the points
    var request = GXmlHttp.create();
    request.open('GET', url, true);
    request.onreadystatechange = function() {
         if (request.readyState == 4) {
              var data = request.responseText;
              var points = eval('('+data+')');

              //create each point from the list
              for (i in points) {
                  var point = new GLatLng(points[i].latitude, points[i].longitude);
                  var marker = createMarker(points[i].id, point, points[i].name, points[i].type);
                  map.addOverlay(marker);
              }
         }
    }
    request.send(null);
}

function createMarker(id, point, name, type) {
    //create the marker with the appropriate icon
    if (type == 'c') {
        var marker = new GMarker(point, {icon: iconCluster} );
        GEvent.addListener(marker, "click", function() {
            zoomMarker(marker);
        });
    } else if (type == 'REF') {
        var marker = new GMarker(point, {icon: iconRef, title: name});
        GEvent.addListener(marker, "click", function() {
            openLocation(point);
        });
    } else {
        var marker = new GMarker(point, {icon: iconSub, title: name});
        GEvent.addListener(marker, "click", function() {
            openLocation(point);
        });
    }
    return marker;
}

function zoomMarker(marker) {
    if (map.getZoom() < 17) {
    map.setCenter(marker.getPoint(), map.getZoom() + 1);
    }
}

function openLocation(point) {
    window.open("/tides/" + point.lat() + "/" + point.lng());
}

window.onload = init;
