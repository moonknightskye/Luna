/**
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: April 21, 2017    Updated: Feb 9, 2018
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

            function remove( instance, isInner ) {
            	var _window = instance.__getScopeWindow();
            	if( _window !== $window ) {
            		_window.__Luna.remove( instance );
            	}
                apollo11.splice( _INTERNAL_DATA.instances, instance );
                _window[ 'lightning-luna_' + instance.getGlobalId() ] = undefined;
            };

            function removeInactive() {
            	apollo11.forEvery( get(), function(luna_instance){
            		$window.setTimeout( function() {
	            		if( luna_instance.getLightningComponent() && !luna_instance.getLightningComponent().isValid()) {
	            			remove( luna_instance );
	            		}
            		}, 0 );
            	});
            };
            
            var _INTERNAL_DATA = {
              instances			: []  
            };
            
            return {
                add		: add,
                get		: get,
                clear	: clear,
                remove	: remove,
                removeInactive:removeInactive
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
				var scanForLunaOnPageNavigate = function(node, isPulltoRefresh) {
					if( node && Object.prototype.toString.call(node) === "[object HTMLDivElement]" ) {
						//console.log("OBSERVE THIS NODE:", node)
						var observer = new MutationObserver( function( mutations ) {
			              mutations.forEach( function( mutation ) {
			                if ( mutation.type === "childList" ) {
			                    if( mutation.addedNodes.length ) {
			                    	var isSet = false;
			                    	apollo11.forEvery( mutation.addedNodes, function( _node ) {
			                    		//console.log("NODE ADDED", _node);
		                    			if( Object.prototype.toString.call(_node) === "[object HTMLDivElement]" ) {
		                    				findLightningLuna( _node );

		                    				 if( isPulltoRefresh && !isSet) {
		                    				 	isSet = true;
		                    				 	var oneContent = apollo11.getElement(".oneContent.active", "SELECT", node);
		                    				 	if( oneContent ) {
		                    				 		scanForLunaOnPageNavigate( oneContent );
		                    				 	}
		                    				 }
		                    			}
			                    	});
			                    }
			                    if( mutation.removedNodes.length ) {
			                    	$window.__Luna.removeInactive();
			                    }
			                } else if( mutation.type === "attributes" && mutation.attributeName === "class") {
			                	//NEW! 2018.2.9 check if oneContent turned inactive
			                	//console.log("DISCONNECT:", node)
			                	if( !node.classList.contains("active") ) {
			                		observer.disconnect();
			                		var oneContent = apollo11.getElement(".oneContent.active", "SELECT");
			                		if( oneContent ) {
		        				 		scanForLunaOnPageNavigate( oneContent );
		        				 		findLightningLuna( oneContent );
		        				 	}
		        				 	$window.__Luna.removeInactive();
			                	}
			                }
			              });    
			            });
			            observer.observe( node, { attributes: true, childList: true, characterData: false } );
			            if( isPulltoRefresh) {
			            	apollo11.waitUntilDOMReady({SELECT:".oneContent.active"}, node, 5).then( function(oneContent){
			            		scanForLunaOnPageNavigate( oneContent );
			            	}, function(error){
								console.log( error );
							});
        				 }
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
					apollo11.waitUntilDOMReady({class:"lightning-luna luna-ready"}, node, 5).then( function(result){
						$window.apollo11.forEvery( result, function( element ) {
							// NEW!! 2018.2.19 check if luna has been initialized already
							if( !element.classList.contains("luna-init") ) {
								var _window = $window.$A.getComponent( element.dataset.globalId ).controller.getWindow();
	                    		var _instance = _window[ 'lightning-luna_' + element.dataset.globalId ];
	                    		if( !_window.webkit ) {
	                    			_window.webkit = $window.webkit;
	                    		}
	                            if( _instance.runJSCommand( _INTERNAL_DATA.initMessage ) ) {
	                            	$window.__Luna.add( _instance );
	                            	element.classList.add("luna-init")
	                            }
							}
                       	}); 
					}, function(error){
						console.log( error );
					});
				};

				(function( title, aura ) {
					//NOTE: force is available only for s1mobile
					if( title !== "Salesforce" && aura ) {
						console.info("Running on Napili Communities");
						function checkIfFinishInit() {
							if( aura.finishedInit && aura.getRoot().isRendered() && $A.getRoot().isValid()) {
								findLightningLuna( $document );
								apollo11.waitUntilDOMReady({id:"ServiceCommunityTemplate"}, $document, 1).then( function(result){
									scanForLunaOnPageNavigate( apollo11.getElement(".cCenterPanel", "SELECT", result) );
								}, function(error){
									console.log( error );
									console.log( "Maybe not running under napili template? then might be running under S1" )
								});
								return;
							}
						};
						$window.requestAnimationFrame( checkIfFinishInit );
					} else if( title === "Salesforce" && aura ){
						console.info("Running on Salesforce1");
						scanForLunaOnPageNavigate( false );

						apollo11.waitUntilDOMReady({select:".stage .oneCenterStage"}, $document, 20).then( function(result){
							findLightningLuna( result );
							scanForLunaOnPageNavigate( result, true );
						}, function(error){
							console.log( error );
						});
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
    
})( typeof window !== "undefined" ? window : this, window.document, typeof window !== "undefined" ? window.parent : this.parent );





