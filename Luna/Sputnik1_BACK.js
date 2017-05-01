/**
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: April 21, 2017    Updated: XXX XX, XXXX
    Sputnik Javascript Utility
    v 1.0.0  
**/

(function( $window, $document, $parent ) {
	"use strict";
   	
   	if ( typeof $window.__Luna === "undefined" ) {
        $window.__Luna = (function(){
            function add( instance ) {
                _INTERNAL_DATA.instances.push( instance );
            };
            
            function get() {
                return _INTERNAL_DATA.instances;
            };
            
            function clear() {
                _INTERNAL_DATA.instances = [];
            };

            function remove( instance ) {
                apollo11.splice( _INTERNAL_DATA.instances, instance );
                var _window = instance.__getScopeWindow();
                _window[ 'lightning-luna_' + instance.getGlobalId() ] = undefined;
            };
            
            var _INTERNAL_DATA = {
              instances			: []  
            };
            
            return {
                add		: add,
                get		: get,
                clear	: clear,
                remove	: remove
            };
        })();
    }

    if ( typeof $window.Sputnik1 !== "undefined" ) {
        console.error( "Sputnik1 has already been initialized", "ERROR" );
        return;
    } else {
        console.info( "[Happy Coding from Sputnik1]" );
    }
    
    $window.Sputnik1 = function() {
        var sputnik1 = {};
        
        function init() {
			//1. Check if the current window is Luna
			_INTERNAL_DATA.isLuna = typeof $window.Luna !== "undefined";
			
			var messageListener = function( event ) { 
				$window.removeEventListener( "message", messageListener, false ); 
			};
			var unloadListener = function( event ) { 
				$window.removeEventListener( "message", messageListener, false ); 
				$window.removeEventListener( "unload", unloadListener, false );
				event.preventDefault();
			};

			if( _INTERNAL_DATA.isLuna ) {
				//2.a If is Luna try to check if she resides on an iFrame
				if( isOniFrame() ) {
					//2.a.1 If is on iFrame, try to send message to parent
					if ( $parent ) {
						_INTERNAL_DATA.isHandshakeDone = true;
						_INTERNAL_DATA.messageSource = $parent;
						sputnik1.beamMessage( {msg:"Hello Earth!"} );
						messageListener = function( event ) {
							//console.log("This is Luna. and your message was: " + event.data);
							if( !event.data.msg ) {
								//var parsedMessage = $window.JSON.parse( event.data );
								apollo11.forEvery( $window.__Luna.get(), function(luna_instance){
									luna_instance.runJSCommand( event.data  );
								});
								console.info( "This is Luna, and your message was: [ *** Secret Code *** ]" );
							} else {
								console.info( "This is Luna, and your message was: " + event.data.msg );
							}
						};
						unloadListener = function( event ) {
							$window.removeEventListener( "message", messageListener, false );
							$window.removeEventListener( "unload", unloadListener, false);
							sputnik1.beamMessage( {msg:"Goodbye Earth!"} );
						  	event.preventDefault();
						};
						console.log("I am Luna on iframe");
					}
				} else {
					console.log("I am Luna on main");
				}
			} else {
				//check if lightning component
				var scanForLunaOnPageNavigate = function(_node) {
					var cCenterPanelDOM = apollo11.getElement("cCenterPanel", "CLASS", _node)[0];
					if( Object.prototype.toString.call(cCenterPanelDOM) === "[object HTMLDivElement]" ) {
						var observer = new MutationObserver( function( mutations ) {
			              mutations.forEach( function( mutation ) {
			                if ( mutation.type === "childList" ) {
			                    if( mutation.addedNodes && mutation.addedNodes.length > 0 ) {
			                    	apollo11.forEvery( mutation.addedNodes, function( node ) {
			                    		findLightningLuna( node );
			                    	});
			                    }
			                    if( mutation.removedNodes && mutation.removedNodes.length > 0 ) {
			                    	apollo11.forEvery( $window.__Luna.get(), function( luna_instance ) {
			                    		if( !luna_instance.getLightningComponent().isValid() ) {
			                    			$window.__Luna.remove( luna_instance );
			                    		}
			                    	});
			                    }
			                }
			              });    
			            });
			            observer.observe( cCenterPanelDOM, { attributes: true, childList: true, characterData: true } );
					} else {
						//2.b If it is not luna, check if the current window is top window
						if( isOniFrame() ) {
							//2.b.1 If it is not luna, and on iFrame, send the message recieved to parent
							console.log("I am NOT Luna on iframe");
							if( $parent ) {
								messageListener = function( event ) {
									if( event.data !== "Hello Earth!" || event.data !== "Goodbye Earth!" ) { return; }
									$parent.postMessage( event.data, event.origin );
						        };
							}
						} else {
							console.log("I am NOT Luna on main");
							messageListener = function( event ) {
								if ( event.data.msg === "Hello Earth!" ) {
									_INTERNAL_DATA.isHandshakeDone = true;
									_INTERNAL_DATA.messageSource = event.source;
									_INTERNAL_DATA.messageOrigin = event.origin;

									console.info( "This is Earth, and your message was: " + event.data.msg )
									console.log( _INTERNAL_DATA.messageOrigin );
									sputnik1.beamMessage( {msg:"Hello Luna!"} )
									sputnik1.beamMessage( _INTERNAL_DATA.initMessage );
								} else if ( event.data.msg === "Goodbye Earth!" ) {
									_INTERNAL_DATA.isHandshakeDone = false;
									_INTERNAL_DATA.messageSource = undefined;
									_INTERNAL_DATA.messageOrigin = "*";

									console.info( "This is Earth, and your message was: " + event.data.msg );
								}
								return;
							};
					}
					}
				};

				var findLightningLuna = function( node ) {
					console.log("scanning for luna", node)
					apollo11.waitUntilDOMReady({class:"lightning-luna luna-ready"}, node, 1).then( function(result){
						$window.apollo11.forEvery( result, function( element ) {
							console.log("found", element)
							var _window = $window.$A.getComponent( element.dataset.globalId ).controller.getWindow();
                    		var _instance = _window[ 'lightning-luna_' + element.dataset.globalId ];
                    		_window.webkit = $window.webkit;
                            _instance.runJSCommand( _INTERNAL_DATA.initMessage );
                            $window.__Luna.add( _instance );
                       	}); 
					}, function(error){
						console.log( error );
					});
				};

				(function( title, aura ) {
					//NOTE: force is available only for s1mobile
					if( title !== "Salesforce1" && aura ) {
						function checkIfFinishInit() {
							if( aura.finishedInit && aura.getRoot().isRendered() && $A.getRoot().isValid()) {
								findLightningLuna( $document );
								apollo11.waitUntilDOMReady({id:"NapiliCommunityTemplate"}, $document, 1).then( function(result){
									aura.run( scanForLunaOnPageNavigate(result) );
								}, function(error){
									console.log( error );
									console.log( "Maybe not running under napili template? then might be running under S1" )
								});
								return;
							}
						};
						$window.requestAnimationFrame( checkIfFinishInit );
					} else if ( title === "Salesforce1" && aura ) {
						function checkIfFinishInit(){
							//document.querySelectorAll(".oneCenterStage .flexipageDefaultAppHomeTemplate")
							if( aura.finishedInit && aura.getRoot().isRendered() && $A.getRoot().isValid()) {
								scanForLunaOnPageNavigate( false );
								apollo11.waitUntilDOMReady({select:".oneCenterStage .flexipageDefaultAppHomeTemplate"}, $document, 3).then( function(result){
									$window.setTimeout(function(){
										console.log("found centerstage")
										findLightningLuna( result );
									},100);
									
								}, function(error){
									console.log( error );
									console.log("doesnt seem like Lightning App page... trying to find it normally")
									findLightningLuna( $document );
								});
							}
						}
						$window.requestAnimationFrame( checkIfFinishInit );
					} else {
						scanForLunaOnPageNavigate( false );
					}
				})( $document.title, $window.$A );
			}
			$window.addEventListener( "message", messageListener, false );
			$window.addEventListener( "unload", unloadListener, false );
		};
        
        sputnik1.beamMessage = function( message ) {
			if( _INTERNAL_DATA.isLuna && !isOniFrame() ) {
				$window.apollo11.forEvery( $window.__Luna.get(), function(luna_instance){
					luna_instance.runJSCommand( message );
				});
			} else {
				if( _INTERNAL_DATA.isHandshakeDone ) {
					_INTERNAL_DATA.messageSource.postMessage( message , _INTERNAL_DATA.messageOrigin );
				} else {
					if( !_INTERNAL_DATA.initMessage ) {
						_INTERNAL_DATA.initMessage = message;
					}
					apollo11.forEvery( $window.__Luna.get(), function(luna_instance){
						if( luna_instance.getGlobalId() === message.params.source_global_id || message.params.source_global_id === "all") {
							luna_instance.runJSCommand( message );
						}
					});
				}
			}
		};
        
        sputnik1.sendSOS = function( name, message ) {
			if( !$window.apollo11.isUndefined( $window.webkit ) ) {
				$window.webkit.messageHandlers[ name ].postMessage( message );
			}
		};


        function isOniFrame() {
            try {
                return $window.self !== $window.top;
            } catch ( e ) {
                return true;
            }
        };
        
        var _INTERNAL_DATA = {
			isLuna			: false,
			isHandshakeDone	: false,
			messageSource	: undefined,
			messageOrigin	: "*",
			initMessage		: undefined
		};
        
        init();
        
        return sputnik1;
    };

    $window.sputnik1 = new $window.Sputnik1(); 
    
})( typeof window !== "undefined" ? window : this, window.document, typeof window !== "undefined" ? window.parent : this.parent );





