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
        //divStyle.marginLeft = "500px";
        //divStyle.width = "80%";

      }
      else {
        obj.click();
        controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
        //divStyle.marginLeft = "0px";
        //divStyle.width = "100%";
      }
      fullScreen = !fullScreen;
    });

    return controlDiv;
}

function BarControll(map) {
    
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';
    controlDiv.style.marginTop = '-50px';


    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '350px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);

    var divRadio = document.createElement('div');
    divRadio.style.position = 'absolute';
    divRadio.style.top = '25px';
    divRadio.style.left = '30px';
    divRadio.style.left = '25px';
    var strRadio = ""

    strRadio = strRadio + '<form accept-charset="UTF-8" action="/managements/change_biru_icon" data-remote="true" format="js" id="biru_icon_id" method="post" name="biru_icon">'
    strRadio = strRadio + '  <div style="margin:0;padding:0;display:inline">'
    strRadio = strRadio + '    <input name="utf8" type="hidden" value="&#x2713;" />'
    strRadio = strRadio + '    <input name="authenticity_token" type="hidden" value="JEzEMF2O+DTDMazjGjDPHR3BNof0wPWpYp3uIceXX7M=" /></div>'
    strRadio = strRadio + '  </div>'
    strRadio = strRadio + '  <select id="disp_type" name="disp_type" onChange="change_icon();" style="width:150px;">'
    strRadio = strRadio + '    <option value="biru_kind">建物種別</option>'
    strRadio = strRadio + '    <option value="siten">支店</option>'
    strRadio = strRadio + '    <option value="area">エリア</option>'
    strRadio = strRadio + '    <option value="shop">営業所</option>'
    strRadio = strRadio + '    <option value="manage_type">管理方式</option>'
    strRadio = strRadio + '    <option value="aki">空室数</option>'
    strRadio = strRadio + '    <option value="age">築年数</option>'
    strRadio = strRadio + '    <option value="num">戸数</option>'
    strRadio = strRadio + '    <option value="jita">自他</option>'
    strRadio = strRadio + '    <option value="atk">アタックランク</option>'
    strRadio = strRadio + '  </select>'
    strRadio = strRadio + '  <input name="s_commit" style="display:none;" type="submit" value="" />'
    strRadio = strRadio + '</form>'

    divRadio.innerHTML = strRadio
    controlDiv.appendChild(divRadio);


    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '75px';
    divA.style.left = '10px';
    divA.id = "biru_icon"

    var strTable = ""
    strTable = strTable + '<table style="margin-left:30px;">'
    strTable = strTable + '   <tbody>'
    strTable = strTable + '     <tr >'
    strTable = strTable + '       <td style="text-align:left;height:20px;width:25px;"><img alt="Marker_blue" src="/assets/marker_blue.png" /></td>'
    strTable = strTable + '       <td style="text-align:left;height:5px;font-size:medium;">アパート</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_yellow" src="/assets/marker_yellow.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">マンション</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_purple" src="/assets/marker_purple.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">分譲M</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_red" src="/assets/marker_red.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">戸建て</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_orange" src="/assets/marker_orange.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">テラス</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_green" src="/assets/marker_green.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">メゾネット</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_gray" src="/assets/marker_gray.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">店舗等</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_gray" src="/assets/marker_gray.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">事務所等</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_white" src="/assets/marker_white.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">その他</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '   </tbody>'
    strTable = strTable + ' </table>'
    
    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    // Set CSS for the control interior.
//   var controlText = document.createElement('div');
//   controlText.style.fontFamily = 'Arial,sans-serif';
//   controlText.style.fontSize = '13px';
//   controlText.style.paddingTop = '1px';
//   controlText.style.paddingBottom = '1px';
//   controlText.style.paddingLeft = '6px';
//   controlText.style.paddingRight = '6px';
//   controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
//   controlUI.appendChild(controlText);



    return controlDiv;
}


function DispControll(map) {

    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';


    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '130px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);


    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '20px';
    divA.style.left = '15px';

    var strTable = ""
    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="ownerChk"  onClick="javascript:dips_owners(ownerChk.checked);" />&nbsp;&nbsp;貸主マーカー</label>'
    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="trustChk" onClick="javascript:dips_trusts(trustChk.checked);" />&nbsp;&nbsp;委託契約ライン</label>'
    strTable = strTable + '<label style="font-size:small;margin-bottom:0px;padding-bottom:0px;clear:both;"><input type="checkbox" id="shopChk" onClick="javascript:dips_shops(shopChk.checked);" checked/>&nbsp;&nbsp;営業所マーカー</label>'
    strTable = strTable + '<label style="font-size:small;margin-bottom:0px;padding-bottom:0px;float:left;margin-left:20px;"><input type="checkbox" name="dispcheck01" id="circle01Chk" onClick="javascript:disp_shop_01(circle01Chk.checked);" />&nbsp;&nbsp;半径1Km</label>'
    strTable = strTable + '<label style="font-size:small;margin-bottom:0px;padding-bottom:0px;float:left;margin-left:20px;"><input type="checkbox" name="dispcheck01" id="circle02Chk" onClick="javascript:disp_shop_02(circle02Chk.checked);" />&nbsp;&nbsp;半径2Km</label>'
    strTable = strTable + '</div>'  
    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    return controlDiv;
   
}

function ResultControll(map) {

    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';


    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '40px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);


    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '15px';
    divA.style.left = '15px';

    var strTable = "";
    strTable = strTable + '&nbsp;&nbsp;&nbsp;<a href="javascript:win_result_biru();"><span style="font-size:small;">建物</span></a>';
    strTable = strTable + '&nbsp;&nbsp;&nbsp;<a href="javascript:win_result_owner();"><span style="font-size:small;margin-left:20px;">貸主</span></a>';
    strTable = strTable + '&nbsp;&nbsp;&nbsp;<a href="javascript:win_result_shop();"><span style="font-size:small;margin-left:20px;">営業所</span></a>';

    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    return controlDiv;

}



function StreetViewControll(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginBottom = '30px';
    controlDiv.style.marginRight = '50px';

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
//      if (!fullScreen) {
      if (document.getElementById("panowide").style.display == "none") {
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
  document.getElementById("map_canvas").style.height = "100%";
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
      ,minZoom:2
    });

    // フルスクリーンラベルを設定
    mapCanvas.controls[google.maps.ControlPosition.TOP_RIGHT].push(new MenuControll(mapCanvas));
    mapCanvas.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(new StreetViewControll(mapCanvas));
    // mapCanvas.controls[google.maps.ControlPosition.TOP_LEFT].push(new FullScreenControl(mapCanvas));

    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new BarControll(mapCanvas));
    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new DispControll(mapCanvas));
    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new ResultControll(mapCanvas));

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