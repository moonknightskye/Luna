(function( $window, $document, $parent ) {
    "use strict";

    var haptic;

    if ( typeof $window.phobos !== "undefined" ) {
        console.error( "phobos has already been initialized", "ERROR" );
        return;
    }


    $window.phobos = (function(){

        var haptic;

        function initHapticFeedback(luna){
            luna.hapticFeedback().then(function(_haptic) {
                haptic = _haptic;
            });
        };

        function playFeedback( type ) {
            if( haptic ) {
                haptic.feedback({type:type}).then(function(success){},function(error){
                    switch(type){
                        case "heavy":
                        case "error":
                            haptic.feedback({type:"nope"});
                            break;
                        case "light":
                        case "success":
                            haptic.feedback({type:"pop"});
                            break;
                        case "medium":
                        case "warning":
                            haptic.feedback({type:"peek"});
                            break;
                    }
                });
            };
        };

        function checkAppVersion( requiredversion ) {
            return new Promise( function ( resolve, reject ) {
                if( !apollo11.isUndefined(luna.getVersion) && luna.getVersion() >= requiredversion) {
                    //luna.showBetaAR();
                    resolve(true);
                } else {
                    window.setTimeout(function(){
                        playFeedback("error");
                    },500);
                    luna.notification().then(function(userNotification){
                        userNotification.show({title:"Latest version of Luna required", badge:0, body:"You are currently running old version of Luna, update to continue", timeInterval:0.5, repeat:false});
                        window.setTimeout(function(){
                            luna.getHtmlFile({
                                path        : "https://luna-10.herokuapp.com/",
                                path_type   : "url"
                            }).then( function( html_file ) {
                                html_file.openWithSafari();
                            });
                        },3500);
                    });
                    reject(true);
                }
            });
        };
        
        function scanElements() {
            apollo11.forEvery( apollo11.getElement("phobos-input"), function(element){
                if( element.classList.contains("input-select-btn") ) {
                    element.addEventListener("click", function(e){
                        playFeedback("medium");
                        initSelect( element )
                    });
                } else if( element.classList.contains("input-text") ) {
                    var textboxelem = apollo11.getElement("input", "SELECT", element);
                    initTextbox( textboxelem )
                } else if( element.classList.contains("input-textarea") ) {
                    var textboxelem = apollo11.getElement("textarea", "SELECT", element);
                    initTextbox( textboxelem )
                } else if( element.classList.contains("button") ) {
                    var afterclick = function(){
                        playFeedback("heavy");
                        element.classList.remove("pressed");
                        element.removeEventListener("transitionend", afterclick);
                    };
                    var ontouch = function(){
                        playFeedback("medium");
                        element.addEventListener("transitionend", afterclick);
                        element.classList.add("pressed");
                    };
                    var onclick = function(){
                        element.addEventListener("transitionend", afterclick);
                        element.classList.add("pressed");
                    };

                    element.addEventListener("touchstart", ontouch);
                    element.addEventListener("click", onclick);
                } else if ( element.classList.contains("input-checkbox") ) {
                    element.addEventListener("change",function(e){
                        playFeedback("medium");
                    });
                }
            });
        };

        function initTextbox( element ) {
            //input = apollo11.getElement("input", "SELECT", input);
            var DOM = apollo11.JSONtoDOM( {
                tag:"SPAN", class:"input-text-clear", events:{click:function(){
                    playFeedback("medium");
                    element.value = "";
                    hideClear();
                }}
            });

            function showClear() {
                if(element.value.length > 0) {
                    if( element.dataset.showClear === "0" ) {
                        element.insertAdjacentElement('afterend', DOM);
                        element.dataset.showClear = "1";
                    }
                }
            };
            function hideClear(){
                if(element.value.length <= 0) {
                    if( element.dataset.showClear === "1" ) {
                        apollo11.removeDOM( DOM );
                        element.dataset.showClear = "0";
                    }
                }
            };

            element.dataset.showClear = 0;

            element.addEventListener("focus",function(e) {
                playFeedback("medium");
                showClear()
            });

            element.addEventListener("keypress",function(e) {
                $window.setTimeout(function(){
                    showClear();
                    hideClear();
                },10);
            });

            element.addEventListener("keydown",function(e) {
                playFeedback("select");
            });

            element.addEventListener("change",function(e) {
                $window.setTimeout(function(){
                    showClear();
                    hideClear();
                },10)
                
            });
        };

        function initSelect( selectelem ) {
            var parent = apollo11.getElement( ".phobos", "SELECT" );
            if(!parent) { return; }

            var selectelem_parent = apollo11.getParent( selectelem, function(_parent){
                if (_parent.classList.contains("phobos-page")) {
                    return _parent;
                }
            });
            if( selectelem_parent ) {
                selectelem_parent.classList.add("back")
            }

            var OPTDOM = [];
            apollo11.forEvery( JSON.parse(selectelem.dataset.choices.replace(/'/g, '"')).choices, function(option){
                var selected = "";
                if( selectelem.dataset.value == option ) {
                    selected = 1;
                }
                OPTDOM.push({
                    tag:"LI", class:"flex-one", children:[
                        {tag:"DIV", data:{value:option, selected:selected}, text:option}
                    ]
                });
            });

            var JSONDOM = {
                tag:"DIV", class:"input-select", data:{active:0, selected:"",requestId:selectelem.dataset.id}, children:[
                    {tag:"DIV", class:"select-body", children:[
                        {tag:"UL", class:"flex-box flex-col", children:OPTDOM}
                    ]}
                ]
            };

            var clickHandler = function( e ) {
                var target = e.target;
                target.removeEventListener( "click", clickHandler );
                
                window.setTimeout(function(){
                    var parent = apollo11.getParent(target,function(_parent){
                        if(_parent.classList.contains("input-select")){
                            return _parent;
                        }
                    });
                    if( parent ) {
                        apollo11.forEvery( apollo11.getElement("ul li div", "ALL", parent), function(optionelem){
                            if( optionelem == target ) {
                                return;
                            }
                            optionelem.dataset.selected = 0;
                        });
                        var transitionEndHandler = function( e ) {
                            e.target.removeEventListener("transitionend", transitionEndHandler, true);
                            var parentTransitionEndHandler = function(e){
                                e.target.removeEventListener("transitionend", parentTransitionEndHandler, true);
                                window.setTimeout(function(){
                                    apollo11.removeDOM( parent, undefined, function() {});
                                },200);
                                selectelem_parent.classList.remove( "back" );
                            };
                            parent.addEventListener("transitionend", parentTransitionEndHandler, true);
                            parent.dataset.active = 0;
                        };
                        target.addEventListener("transitionend", transitionEndHandler, true);
                        target.dataset.selected = 1;
                        selectelem.dataset.value = target.dataset.value;
                        parent.dataset.selected = target.dataset.value;
                        playFeedback("medium");

                        apollo11.getElement("SPAN","SELECT", selectelem).innerText = target.dataset.value;

                        var event = new Event("change");
                        selectelem.dispatchEvent(event);
                    }
                },10);
            };

            apollo11.appendJSONDOM( JSONDOM, parent, function(DOM){
                window.setTimeout(function(){
                   DOM.dataset.active = 1;
                },10);

                apollo11.forEvery( apollo11.getElement("ul li div", "ALL", DOM), function(optionelem,index){
                    optionelem.addEventListener("click", clickHandler);
                    optionelem.style.transitionDelay = 0.1 + (0.10 * index) + "s";
                });
            });
        };

        return {
            initHapticFeedback          : initHapticFeedback,
            playFeedback                : playFeedback,
            scanElements                : scanElements,
            checkAppVersion             : checkAppVersion
        };

    })();

    $window.addEventListener("load", function(){
        $window.phobos.scanElements();
    });

})( typeof window !== "undefined" ? window : this, document, typeof window !== "undefined" ? window.parent : this.parent );




























