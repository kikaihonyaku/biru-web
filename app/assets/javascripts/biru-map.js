/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// グローバル変数定義
var infoWnd;  // 吹き出しウィンドウ
var panoramaOptions; // ストリートビュー定義
var panorama;
var mapCanvas;

// フルスクリーンを表示するボタン定義
function FullScreenControl(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '13px';
    controlText.style.paddingTop = '1px';
    controlText.style.paddingBottom = '1px';
    controlText.style.paddingLeft = '6px';
    controlText.style.paddingRight = '6px';
    controlText.innerHTML = '<strong>Full Screen</strong>';
    controlUI.appendChild(controlText);

    var fullScreen = false;
    var mapDiv = map.getDiv();
    var divStyle = mapDiv.style;
    if (mapDiv.runtimeStyle)
            divStyle = mapDiv.runtimeStyle;
    var originalPos = divStyle.position;
    var originalWidth = divStyle.width;
    var originalHeight = divStyle.height;
    var originalTop = divStyle.top;
    var originalLeft = divStyle.left;
    var originalZIndex = divStyle.zIndex;

    var bodyStyle = document.body.style;
    if (document.body.runtimeStyle)
            bodyStyle = document.body.runtimeStyle;
    var originalOverflow = bodyStyle.overflow;

    // Setup the click event listener
    google.maps.event.addDomListener(controlUI, 'click', function() {
            var obj = document.getElementById("simple-menu");

            var center = map.getCenter();
            if (!fullScreen) {

                    obj.click();

                    divStyle.position = "fixed";
                    divStyle.width = "100%";
                    divStyle.height = "100%";
                    divStyle.top = "0";
                    divStyle.left = "0";
                    divStyle.zIndex = "100";
                    bodyStyle.overflow = "hidden";
                    controlText.innerHTML = '<strong>Exit full screen</strong>';
            }
            else {

                    obj.click();

                    if (originalPos == "")
                            divStyle.position = "relative";
                    else
                            divStyle.position = originalPos;
                    divStyle.width = originalWidth;
                    divStyle.height = originalHeight;
                    divStyle.top = originalTop;
                    divStyle.left = originalLeft;
                    divStyle.zIndex = originalZIndex;
                    bodyStyle.overflow = originalOverflow;
                    controlText.innerHTML = '<strong>Full Screen</strong>';
            }
            fullScreen = !fullScreen;
            google.maps.event.trigger(map, 'resize');
            map.setCenter(center);
    });

    return controlDiv;
}


function MenuControll(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '13px';
    controlText.style.paddingTop = '1px';
    controlText.style.paddingBottom = '1px';
    controlText.style.paddingLeft = '6px';
    controlText.style.paddingRight = '6px';
    controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
    controlUI.appendChild(controlText);

    var fullScreen = false;
    var mapDiv = map.getDiv();
    var divStyle = mapDiv.style;

    // Setup the click event listener
    google.maps.event.addDomListener(controlUI, 'click', function() {
      var obj = document.getElementById("simple-menu");

      if (!fullScreen) {
        obj.click();
        controlText.innerHTML = '<strong>メニュー非表示</strong>';
      }
      else {
        obj.click();
        controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
      }
      fullScreen = !fullScreen;
    });

    return controlDiv;
}

function StreetViewControll(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(1,0,0,0.4)';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '13px';
    controlText.style.paddingTop = '1px';
    controlText.style.paddingBottom = '1px';
    controlText.style.paddingLeft = '6px';
    controlText.style.paddingRight = '6px';
    controlText.innerHTML = '<strong>ストリートビュー&nbsp;&nbsp;表示</strong>';
    controlUI.appendChild(controlText);

    var fullScreen = false;
    var mapDiv = map.getDiv();

    // Setup the click event listener
    google.maps.event.addDomListener(controlUI, 'click', function() {
      if (!fullScreen) {
        street_veiw_window();
        refresh_view(panorama.getPosition());

        controlText.innerHTML = '<strong>ストリートビュー非表示</strong>';
      }
      else {
        init_display()
        controlText.innerHTML = '<strong>ストリートビュー&nbsp;&nbsp;表示</strong>';
      }
      fullScreen = !fullScreen;
    });

    return controlDiv;
}

// ストリートビューを非表示にして map_canvasの高さを設定
function init_display(){
  document.getElementById("map_canvas").style.height = "95%";
  document.getElementById("panowide").style.height = "0px";
  document.getElementById("panowide").style.display = "none";
}

// ストリートビューの表示を設定します。
function street_veiw_window(){
    document.getElementById("map_canvas").style.height = "50%";
    document.getElementById("panowide").style.height = "50%";
    document.getElementById("panowide").style.display = "block";
}


// ストリートビューを表示
function view_disp(disp_flg, lat, lng){

    if(disp_flg == true){
      // ストリートビュー　表示設定
      street_veiw_window();
      refresh_view(new google.maps.LatLng(lat,lng));

    }else{
      // ストリートビューを非表示に設定
      init_display();
    }
}

/* ストリートビューのリフレッシュ */
function refresh_view(pos){
    // ストリートビューがないところを一度選択するとそれ以降他もも表示されなくなるので、再度生成する。
    panorama = new  google.maps.StreetViewPanorama(document.getElementById("panowide"), panoramaOptions);
    panorama.setPosition(pos);
    panorama.setPov(panoramaOptions.pov);
    mapCanvas.setStreetView(panorama);
}

// ストリートビューを閉じます
function sv_init(){
    init_display();
}

// 円を描きます
function create_circle(size, mapCanvas, pos){
  var myCircle = new google.maps.Circle({
    map : mapCanvas
    ,center : pos
    ,strokeColor: '#0000FF' /* ストロークの色 */
    ,strokeOpacity: 0.8 /* ストロークの透明度 */
    ,strokeWeight: 2 /* ストロークの幅 */
    ,fillColor: '#0000FF' /* フィルの色 */
    ,fillOpacity: 0.35 /* フィルの透明度 */
    ,fillColor: "#0000FF"
  });

  myCircle.setRadius(size); // メートル単位で指定
  myCircle.set("visible",false);

  return myCircle
}

/* マーカーを作成 */
function createMarker(opts){
  var marker = new google.maps.Marker(opts);

  google.maps.event.addListener(marker, "click", function(){
    // write_build(opts.info_msg);

    infoWnd.close();
    infoWnd.setContent(opts.html);
    infoWnd.open(opts.map, marker);
    opts.map.panTo(opts.position);

    marker.set("visible", true);

    if(document.getElementById("panowide").style.display != "none"){
      refresh_view(opts.position);
    }

  });

  return marker;
}

// 地図の初期設定を行います。
function init_map(){

    /* 地図を作成 */
    var mapDiv = document.getElementById("map_canvas");
    mapCanvas = new google.maps.Map(mapDiv, {
      mapTypeId : google.maps.MapTypeId.ROADMAP
      ,scaleControl: true
    });

    // フルスクリーンラベルを設定
    mapCanvas.controls[google.maps.ControlPosition.TOP_RIGHT].push(new MenuControll(mapCanvas));
    mapCanvas.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(new StreetViewControll(mapCanvas));
    // mapCanvas.controls[google.maps.ControlPosition.TOP_LEFT].push(new FullScreenControl(mapCanvas));

    /*----------------------------------------------------------------------*/
    /* ストリートビューオブジェクトを作成 （これはcreate markerを呼び出す前に定義する。）*/
    /*----------------------------------------------------------------------*/
    panoramaOptions = {
      position:mapCanvas.getCenter(),
      pov:{heading: 180,pitch:0,zoom:0}
    };
    panorama = new  google.maps.StreetViewPanorama(document.getElementById("panowide"), panoramaOptions);

    mapCanvas.setStreetView(panorama);
    google.maps.event.addListener(panorama, 'position_changed', function()
    {
      var positionPegman = panorama.getPosition();

      // ストリートビューが表示されていなかったら表示
      if( document.getElementById("panowide").style.display == "none" ){
        view_disp(true, positionPegman.latitude, positionPegman.longitude);
      }

      //ペグマン位置変更イベント
      mapCanvas.panTo(positionPegman);
    });

    // infoウィンドウを１つだけ作成
    infoWnd = new google.maps.InfoWindow();


  return mapCanvas;
}