 (function( $window, $document ) {
  "use strict";
 
      $window.App = (function(){

            function init(){};

            function activatePage( luna ) {

              var app_content = utility.getElement("app_content", "id");
              var debug = utility.getElement(".debug", "SELECT");
              var webview;
              var avplayer;

              $window.URL = $window.URL || $window.webkitURL;

              luna.ibeacon().then(function(ibeacon){

                luna.debug( "ibeacon: OK");

                ibeacon.addEventListener("didUpdate", function(state){
                  luna.debug( "ibeacon didUpdate: " + state.label);
                })

                ibeacon.addEventListener("onRange", function(beacon){
                  beaconscan.innerText = "Ranging: " + beacon.proximity.code;
                })

                ibeacon.addEventListener("onMonitor", function(beacon){
                  monitorscan.innerText = "Monitor: " + beacon.state.code;
                })

                getallmonitored.addEventListener( "click", function() {
                  ibeacon.getMonitoredBeacons().then(function(result){
                    var total = result.monitor.length + result.range.length;
                    luna.debug("ibeacon.getMonitoredBeacons: OK");
                    getallmonitored.innerText = "Get All Beacons: " + total;
                    console.log( result );
                  }, function(error){
                    luna.debug("ibeacon.getMonitoredBeacons: " + error);
                    getallmonitored.innerText = "Get All Beacons: 0";
                  });
                })

                beacontransmit.addEventListener( "click", function() {
                  ibeacon.transmit({uiid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"}).then(function(result){
                    luna.debug("ibeacon.transmit: OK");
                  }, function(error){
                    luna.debug("ibeacon.transmit: " + error);
                  });
                })

                beaconstop.addEventListener( "click", function() {
                  ibeacon.stop().then(function(result){
                    luna.debug("ibeacon.stop: OK");
                  }, function(error){
                    luna.debug("ibeacon.stop: " + error);
                  });
                })

                beaconscan.addEventListener( "click", function() {
                  ibeacon.startRangingScan({uiid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"}).then(function(result){
                    luna.debug("ibeacon.ranging: OK");
                  }, function(error){
                    luna.debug("ibeacon.ranging: " + error);
                  });
                })
                stopbeaconscan.addEventListener( "click", function() {
                  ibeacon.stopRangingScan({uiid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"}).then(function(result){
                    luna.debug("ibeacon.stopranging: OK");
                    beaconscan.innerText = "Ranging";
                  }, function(error){
                    luna.debug("ibeacon.stopranging: " + error);
                  });
                })

                monitorscan.addEventListener( "click", function() {
                  ibeacon.startMonitoringScan({uiid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"}).then(function(result){
                    luna.debug("ibeacon.monitor: OK");
                  }, function(error){
                    luna.debug("ibeacon.monitor: " + error);
                  });
                })
                stopmonitorscan.addEventListener( "click", function() {
                  ibeacon.stopMonitoringScan({uiid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"}).then(function(result){
                    luna.debug("ibeacon.stopmonitor: OK");
                    monitorscan.innerText = "Monitor";
                  }, function(error){
                    luna.debug("ibeacon.stopmonitor: " + error);
                  });
                })

                beaconstopallscan.addEventListener( "click", function() {
                  ibeacon.stopAllScan().then(function(result){
                    luna.debug("ibeacon.stopAllScan: OK");
                    monitorscan.innerText = "Monitor";
                    beaconscan.innerText = "Ranging";
                  }, function(error){
                    luna.debug("ibeacon.stopAllScan: " + error);
                  });
                })

              }, function(error){
                luna.debug( "no ibeacon: " + error);
              })
              

              // https://login.salesforce.com/?un=admin%40swtt16auto.demo&pw=sfdcj111
              luna.getServiceLiveAgent({
                  liveAgentPod: "d.la1-c2-ukb.salesforceliveagent.com",
                  orgId: "00D28000000bEbc",
                  deploymentId: "572280000008Sf7",
                  buttonId:"573280000004Hmi",
                  visitorName: "長谷川 聡"
                }).then( function(serviceliveagent){
                  
                serviceliveagent.removeEventListener("stateDidChange")
                serviceliveagent.addEventListener("stateDidChange", function(state){
                  luna.debug( "serviceliveagent stateDidChange: " + state.label);
                });

                serviceliveagent.removeEventListener("didEnd")
                serviceliveagent.addEventListener("didEnd", function(reason){
                  luna.debug( "serviceliveagent didEnd: " + reason.label);
                  luna.notification().then(function(userNotification){
                      userNotification.show({title:"Service LiveAgent Stopped", badge:0, body:reason.label, timeInterval:0.5, repeat:false});
                  });
                });

                serviceliveagent.clearPrechatObject().then(function(result){
                  luna.debug("serviceliveagent.clearPrechatObject: OK");
                }, function(error){
                  luna.debug("serviceliveagent.clearPrechatObject: ERROR");
                });

                //search for Contact
                serviceliveagent.addPrechatObject({
                  entityName        : "Contact",
                  saveToTranscript  : "Contact",
                  linkToEntityName  : "Case",
                  linkToEntityField : "ContactId",
                  fields            : [
                    {label:"First Name", value:"聡", fieldName:"FirstName", doFind:true, isExactMatch:true, doCreate:true},
                    {label:"Last Name", value:"長谷川", fieldName:"LastName", doFind:true, isExactMatch:true, doCreate:true},
                    {label:"Email", value:"tethom8+hasegawa@gmail.com", fieldName:"Email", doFind:true, isExactMatch:true, doCreate:true}
                  ]
                }).then(function(result){
                  luna.debug("serviceliveagent.addPrechatObject: OK");
                }, function(error){
                  luna.debug("serviceliveagent.addPrechatObject: ERROR");
                });

                // //create a case and show it
                serviceliveagent.addPrechatObject({
                  entityName        : "Case",
                  saveToTranscript  : "Case",
                  showOnCreate      : true,
                  fields            : [
                    {label:"Subject", value:"Live Agent Chat Session", fieldName:"Subject", doCreate:true}
                  ]
                }).then(function(result){
                  luna.debug("serviceliveagent.addPrechatObject: OK");
                }, function(error){
                  luna.debug("serviceliveagent.addPrechatObject: ERROR");
                });


                liveagent.addEventListener( "click", function() {
                  serviceliveagent.checkAvailability().then(function(isavailable){
                    if(isavailable) {
                      luna.debug("serviceliveagent.checkAvailability: available");
                      serviceliveagent.chat().then(function(result){
                        console.log(result);
                      }, function(error){
                        console.log(error);
                      });
                    } else {
                      luna.debug("serviceliveagent.checkAvailability: not available");
                      luna.notification().then(function(userNotification){
                          userNotification.show({title:"Service LiveAgent", badge:0, body:"Agent not Available", timeInterval:0.5, repeat:false});
                      });
                    }
                  })
                  
                })

              })

              sos.addEventListener( "click", function() {
                luna.getServiceSOS().then( function(servicesos){
                  servicesos.removeEventListener("stateDidChange")
                  servicesos.addEventListener("stateDidChange", function(state){
                    luna.debug( "servicesos stateDidChange: " + state.label);
                  });
                  servicesos.removeEventListener("didConnect")
                  servicesos.addEventListener("didConnect", function(state){
                    luna.debug( "servicesos didConnect");
                  });
                  servicesos.removeEventListener("didStop")
                  servicesos.addEventListener("didStop", function(reason){
                    luna.debug( "servicesos didStop: " + reason.label);
                    luna.notification().then(function(userNotification){
                        userNotification.show({title:"Service SOS Stopped", badge:0, body:reason.label, timeInterval:0.5, repeat:false});
                    });
                  });
                  servicesos.call({
                    email       : "mcivil@salesforce.com",
                    pod         : "d.la1-c2-ukb.salesforceliveagent.com",
                    org         : "00D28000000bEbc",
                    deployment  : "0NW280000004Cfv",
                    autoConnect : true
                  }).then(function(result){
                    luna.debug("servicesos.start: OK");
                  }, function(error){
                    luna.debug("servicesos.start: ERROR");
                  });
                });

              });

              setting.addEventListener( "click", function() {
                luna.settings();
              });

              utility.getElement( "silentcamera", "id" ).addEventListener( "click", function() {
                luna.getHtmlFile({
                    filename:   "avcapture_camera.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    luna.debug( "luna.getHtmlFile: " );
                    luna.debug( html_file )
                    var camerascreen = {
                        Width : 375/1.5,
                        Height  : 667/2.6
                    };
                    luna.getNewWebview({
                      html_file: html_file,
                      property: {
                        // frame: {
                        //   height:   camerascreen.Height,
                        //   width:    camerascreen.Width,
                        //   y:        100,
                        //   x:        70
                        // },
                        opacity:    0,
                        isOpaque:   false
                      }
                    }).then( function( result ){

                      webview = result;

                      luna.debug( "luna.getNewWebview: " + webview.getID() );

                      webview.load().then(function(result){
                        luna.debug( "webview.load: " + result );
                      });

                      webview.onLoad().then(function(result){
                        luna.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        luna.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        luna.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        luna.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {
                          // frame: {
                          //   height:   camerascreen.Height,
                          //   width:    camerascreen.Width,
                          //   y:        120,
                          //   x:        70
                          // },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          luna.debug( "webview.setProperty: " + result );
                        });

                      });

                    },function( error ){
                      luna.debug( error )
                    });


                }, function(error){
                    luna.debug( error )
                });
              });
              //utility.getElement( "silentcamera", "id" ).click();




              utility.getElement( "qrcode", "id" ).addEventListener( "click", function() {
                luna.getHtmlFile({
                    filename:   "avcapture.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    luna.debug( "luna.getHtmlFile: " );
                    luna.debug( html_file )
                    var camerascreen = {
                        Width : 375/1.5,
                        Height  : 667/2.6
                    };
                    luna.getNewWebview({
                      html_file: html_file,
                      property: {
                        frame: {
                          height:   camerascreen.Height,
                          width:    camerascreen.Width,
                          y:        100,
                          x:        70
                        },
                        opacity:    0,
                        isOpaque:   false
                      }
                    }).then( function( result ){

                      webview = result;

                      luna.debug( "luna.getNewWebview: " + webview.getID() );

                      webview.load().then(function(result){
                        luna.debug( "webview.load: " + result );
                      });

                      webview.onLoad().then(function(result){
                        luna.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        luna.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        luna.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        luna.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {frame: {
                            height:   camerascreen.Height,
                            width:    camerascreen.Width,
                            y:        120,
                            x:        70
                          },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          luna.debug( "webview.setProperty: " + result );
                        });

                      });

                    },function( error ){
                      luna.debug( error )
                    });


                }, function(error){
                    luna.debug( error )
                });
              });

              //utility.getElement( "qrcode", "id" ).click()

              var counter = 1;
              var evtid_1, evtid_2, evtid_3;
              luna.addEventListener( "shakestart", function(){
                luna.debug( "SHAKE IT BABY GIRL" );
              }).then(function( id ) {
                luna.debug( "luna.addEventListener: shakestart " + id);
                evtid_1 = id;
              });
              luna.addEventListener( "shakestart", function(){
                luna.debug( "SHAKE IT BABY BOY" );
              }).then(function( id ) {
                luna.debug( "luna.addEventListener: shakestart " + id);
                evtid_2 = id;
              });
              luna.addEventListener( "shakeend", function(){
                luna.debug( "SHE SHOOKED IT: " + counter);
                counter++;

                if( counter > 3 ) {
                  luna.removeEventListener( "shakestart" ).then(function(result){
                    luna.debug( "luna.removeEventListener: shakestart " + result );
                  },function(error){
                    luna.debug( "luna.removeEventListener: shakestart " + error );
                  });
                  luna.removeEventListener( "shakeend", evtid_3 ).then(function(result){
                    luna.debug( "luna.removeEventListener: shakeend " + result );
                  },function(error){
                    luna.debug( "luna.removeEventListener: shakeend " + error );
                  });
                }
              }).then(function( id ) {
                luna.debug( "luna.addEventListener: shakeend " + id);
                evtid_3 = id;
              });

              utility.getElement( "closeme", "id" ).addEventListener( "click", function() {
                var selfwebview = luna.getMainWebview();
                  selfwebview.setProperty( {frame: {
                        height:   320,
                        y:        300
                      },
                      opacity:0
                    }, { duration:1.0, delay:0 } ).then(function(result){
                      luna.debug( "webview.setProperty: " + result );
                      luna.closeWebview( selfwebview ).then(function(result){
                        luna.debug( "webview.closeWebview: " + result );
                      });
                  });
              });

              utility.getElement( "icon0", "id" ).addEventListener( "click", function() {
                luna.changeIcon({name:"de"}).then(function(result){
                  luna.debug( "luna.changeIcon: " + result );
                },function(error){
                  luna.debug( "luna.changeIcon: " + error );
                })
              });
              utility.getElement( "icon1", "id" ).addEventListener( "click", function() {
                luna.changeIcon({name:"bluemoon"}).then(function(result){
                  luna.debug( "luna.changeIcon: " + result );
                },function(error){
                  luna.debug( "luna.changeIcon: " + error );
                })
              });
              utility.getElement( "icon2", "id" ).addEventListener( "click", function() {
                luna.changeIcon({name:"redmoon"}).then(function(result){
                  luna.debug( "luna.changeIcon: " + result );
                },function(error){
                  luna.debug( "luna.changeIcon: " + error );
                })
              });

              utility.getElement( "getvideo2", "id" ).addEventListener( "click", function() {
                  luna.getVideoFile({
                    filename:   "video 2.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    luna.debug( "luna.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    luna.getNewAVPlayer({
                      video_file: video_file,
                      property: {
                        frame: {
                          height:   320,
                          y:        300
                        },
                        opacity:    1,
                        autoPlay:   true,
                        mute:       false
                      }
                    }).then(function( avplayer2 ){

                      luna.getMainWebview().appendAVPlayer({
                        avplayer: avplayer2,
                        isFixed: false
                      }).then( function(result){
                        luna.debug( "appendAVPlayer: " + result )
                      });


                      luna.debug( "luna.getNewAVPlayer: " +  avplayer2.getID());
                    }, function(error){
                      luna.debug( error );
                    })



                  },function(error){
                    luna.debug( error );
                  });


              });

              utility.getElement( "getvideo1", "id" ).addEventListener( "click", function() {
                  
                luna.getHtmlFile({
                    filename:   "videoplayer.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    luna.debug( "luna.getHtmlFile: " );
                    luna.debug( html_file )

                    luna.getNewWebview({
                      html_file: html_file,
                      property: {
                        frame: {
                          height:   100,
                          width:    150,
                          y:        560,
                          x:        300
                        },
                        opacity:    0
                      }
                    }).then( function( result ){

                      webview = result;

                      luna.debug( "luna.getNewWebview: " + webview.getID() );

                      webview.load().then(function(result){
                        luna.debug( "webview.load: " + result );
                      });

                      webview.onLoad().then(function(result){
                        luna.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        luna.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        luna.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        luna.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {frame: {
                            height:   100,
                            width:    150,
                            y:        560,
                            x:        218
                          },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          luna.debug( "webview.setProperty: " + result );
                        });

                      });

                    },function( error ){
                      luna.debug( error )
                    });


                }, function(error){
                    luna.debug( error )
                })


              });

              utility.getElement( "play", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.play().then( function(result){
                    luna.debug( "avplayer.play: " + result );
                  });
                }
              });
              utility.getElement( "pause", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.pause().then( function(result){
                    luna.debug( "avplayer.pause: " + result );
                  });
                }
              });
              utility.getElement( "seek", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.seek({seconds:2.0}).then( function(result){
                    luna.debug( "avplayer.seek: " + result );
                  }, function(error){
                    luna.debug( "avplayer.seek: " + error );
                  });
                }
              });


              utility.getElement( "takeVideo", "id" ).addEventListener( "click", function() {
                luna.takeVideo({from:"CAMCORDER"}).then( function(videoFile){
                  luna.debug( "luna.takeVideo:" );

                  // videoFile.getFullResolutionDOM().then( function( DOM ){
                  //   luna.debug( "videoFile.getBase64Binary: YAY" );

                  //   debug.appendChild( DOM );

                  // }, function(error){
                  //   luna.debug( "videoFile.getBase64Binary: " + error );
                  // });
                  luna.getNewAVPlayer({
                    video_file: videoFile,
                    property: {
                      frame: {
                        height:   320,
                        y:        600
                      },
                      opacity:    1,
                      autoPlay:   true,
                      mute:       false
                    }
                  }).then(function( avplayer2 ){

                    luna.getMainWebview().appendAVPlayer({
                      avplayer: avplayer2,
                      isFixed: false
                    }).then( function(result){
                      luna.debug( "appendAVPlayer: " + result )
                    });


                    luna.debug( "luna.getNewAVPlayer: " +  avplayer2.getID());
                  }, function(error){
                    luna.debug( error );
                  })


                }, function(error){
                  luna.debug( "luna.takeVideo: " + error );
                });
                
              });


              utility.getElement( "getVideo", "id" ).addEventListener( "click", function() {
                luna.takeVideo({from:"VIDEO_LIBRARY"}).then( function(videoFile){
                  luna.debug( "luna.takeVideo:" );

                  // videoFile.getFullResolutionDOM().then( function( DOM ){
                  //   luna.debug( "videoFile.getBase64Binary: YAY" );

                  //   debug.appendChild( DOM );

                  // }, function(error){
                  //   luna.debug( "videoFile.getBase64Binary: " + error );
                  // });
                  luna.getNewAVPlayer({
                    video_file: videoFile,
                    property: {
                      frame: {
                        height:   320,
                        y:        300
                      },
                      opacity:    1,
                      autoPlay:   true,
                      mute:       false
                    }
                  }).then(function( avplayer2 ){

                    luna.getMainWebview().appendAVPlayer({
                      avplayer: avplayer2,
                      isFixed: false
                    }).then( function(result){
                      luna.debug( "appendAVPlayer: " + result )
                    });


                    luna.debug( "luna.getNewAVPlayer: " +  avplayer2.getID());
                  }, function(error){
                    luna.debug( error );
                  })


                }, function(error){
                  luna.debug( "luna.takeVideo: " + error );
                });

              });




              utility.getElement( "takePhoto", "id" ).addEventListener( "click", function() {
                luna.takePhoto({from:"CAMERA"}).then( function(imageFile){
                    luna.debug( "luna.takePhoto: OK" );
                    luna.debug( "luna.takePhoto: " + imageFile.getFilePath());

                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    // imageFile.move({
                    //     to:  "Camera Roll",
                    //     isOverwrite: true
                    // }).then(function(url){
                    //     luna.debug("file.moveFile: " + imageFile.getFilePath())
                    // }, function(error){
                    //     luna.debug("file.moveFile: " + imageFile)
                    // })

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      luna.debug( "imageFile.getBase64Binary: YAY" );

                      DOM.classList.add("scale");
                      debug.appendChild( DOM );

                    }, function(error){
                      luna.debug( "imageFile.getBase64Binary: " + error );
                    });

                    // imageFile.getEXIFInfo().then( function(value){
                    //   luna.debug( value );
                    // }, function(error){
                    //   luna.debug( "imageFile.getEXIFInfo: " + error );
                    // });

                }, function(error){
                    luna.debug( "luna.takePhoto: " + error );
                });
              });

              utility.getElement( "getPhoto", "id" ).addEventListener( "click", function() {
                  luna.takePhoto({from:"PHOTO_LIBRARY"}).then( function(imageFile){

                    luna.debug( "webview.takePhoto: " + imageFile.getFilename() + " " + imageFile.getFileExtension());


                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:50}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:10}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      luna.debug( "imageFile.getBase64Binary: YAY" );

                      DOM.classList.add("scale");

                      debug.appendChild( DOM );

                    }, function(error){
                      luna.debug( "imageFile.getBase64Binary: " + error );
                    });

                    imageFile.getEXIFInfo().then( function(value){
                      luna.debug( value );
                    }, function(error){
                      luna.debug( "imageFile.getEXIFInfo: " + error );
                    });



                  }, function(error){
                    luna.debug( "webview.takePhoto: " + error );
                  })
              });



              utility.getElement( "close", "id" ).addEventListener( "click", function() {
                  webview.setProperty( {frame: {
                        height:   320,
                        y:        300
                      },
                      opacity:0
                    }, { duration:1.0, delay:0 } ).then(function(result){
                      luna.debug( "webview.setProperty: " + result );
                      luna.closeWebview( webview ).then(function(result){
                        luna.debug( "webview.closeWebview: " + result );
                      });
                  });
              });

              utility.getElement( "move", "id" ).addEventListener( "click", function() {

                  luna.getVideoFile({
                    filename:   "sample.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    luna.debug( "luna.getVideoFile:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    video_file.move({
                      to:  "movefolder",
                      isOverwrite: true
                    }).then(function(url){
                      luna.debug("file.moveFile: " + video_file.getFilePath())
                    }, function(error){
                      luna.debug("file.moveFile: " + error)
                    })


                  },function(error){

                    luna.getVideoFile({
                      filename:   "sample.mp4",
                      path:       "movefolder", 
                      path_type:  "document"
                    }).then(function( video_file ){
                      luna.debug( "luna.getVideoFile: " +  video_file.getFilename() + " " + video_file.getFileExtension() );

                      video_file.move({
                        to:  "",
                        isOverwrite: true
                      }).then(function(url){
                        luna.debug("file.moveFile: " + video_file.getFilePath())
                      }, function(error){
                        luna.debug("file.moveFile: " + error)
                      })


                    },function(error){
                      luna.debug( error );
                    });

                  });
              });

              utility.getElement( "rename", "id" ).addEventListener( "click", function() {

                  luna.getFile({
                    filename:   "rename.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    luna.debug( "luna.getFile: (old filename) " +  file.getFilename());

                    file.rename({
                      filename:  "newname.mp4"
                    }).then(function(url){
                      luna.debug( "luna.getFile: (new filename) " +  file.getFilename());
                    }, function(error){
                      luna.debug("file.renameFile: " + error)
                    })
                  },function(error){
                    //luna.debug( error );

                    luna.getFile({
                      filename:   "newname.mp4",
                      path_type:  "document"
                    }).then(function( file ){
                      luna.debug( "luna.getFile: (old filename) " +  file.getFilename());

                      file.rename({
                        filename:  "rename.mp4"
                      }).then(function(url){
                        luna.debug( "luna.getFile: (new filename) " +  file.getFilename());
                      }, function(error){
                        luna.debug("file.renameFile: " + error)
                      })
                    },function(error){
                      luna.debug( error );
                    });

                  });
              });


              utility.getElement( "copy", "id" ).addEventListener( "click", function() {

                  luna.getFile({
                    filename:   "video 1.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    luna.debug( "luna.getFile: " +  file.getFilename());

                    file.copy({
                      to:  "copyfolder"
                    }).then(function(url){
                      luna.debug("file.copyFile: " + url)
                    }, function(error){
                      luna.debug("file.copyFile: " + error)
                    })

                  },function(error){
                    luna.debug( error );
                  });
              });

              utility.getElement( "delete", "id" ).addEventListener( "click", function() {

                  luna.getFile({
                    filename:   "video 1.mp4",
                    path: "copyfolder",
                    path_type:  "document"
                  }).then(function( file ){
                    luna.debug( "luna.getFile: " +  file.getFilename());

                    file.delete().then(function(result){
                      luna.debug("file.delete: " + result)
                    }, function(error){
                      luna.debug("file.delete: " + error)
                    })

                  },function(error){
                    luna.debug( error );
                  });

                  
              });

              utility.getElement( "download", "id" ).addEventListener( "click", function() {

                // luna.getFile({
                //   path    : "http://all-free-download.com/free-photos/download/english_love_picture_burning_165644_download.html"
                // }).then( function(file){

                //   luna.debug("luna.getFile: " + file.getFilePath())

                //   file.onDownload().then( function(result){
                //     luna.debug("file.onDownload: " + result)
                //   }, function(error){
                //     luna.debug("file.onDownload: " + error)
                //   });

                //   file.onDownloading(function(progress){
                //     luna.debug( "onDownloading: " + progress + "%" );
                //   }).then(function(result){
                //     luna.debug( "file.onDownloading: " + result );
                //   }, function(error){
                //     luna.debug( "file.onDownloading: " + error );
                //   });

                //   file.onDownloaded().then( function(result){
                //     luna.debug("file.onDownloaded: " + result)
                //   }, function(error){
                //     luna.debug("file.onDownloaded: " + error)
                //   });

                //   file.download({
                //     isOverwrite   : true
                //   }).then(function(result){
                //     luna.debug("file.download: ok" + result)
                //   },function(error){
                //     luna.debug("file.download: error" + error)
                //   });

                // }, function(error){
                //   luna.debug("luna.getFile: " + error)
                // })



                luna.getImageFile({
                  path    : "https://goo.gl/cl7FKy"
                }).then( function(file){

                  luna.debug("luna.getFile1: " )
                  luna.debug(file)

                  file.onDownload().then( function(result){
                    luna.debug("file.onDownload1: " + result)
                  }, function(error){
                    luna.debug("file.onDownload1: " + error)
                  });

                  file.onDownloading(function(progress){
                    luna.debug( "onDownloading1: " + progress + "%" );
                  }).then(function(result){
                    luna.debug( "file.onDownloading1: " + result );
                  }, function(error){
                    luna.debug( "file.onDownloading1: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    luna.debug("file.onDownloaded1: ")
                    luna.debug(result)

                    // file.copy({
                    //   to:  "copyfolder"
                    // }).then(function(url){
                    //   luna.debug("file.copyFile: " + url)
                    // }, function(error){
                    //   luna.debug("file.copyFile: " + error)
                    // })

                    file.getResizedDOM({quality:10}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM1: " );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM1: " + error );
                    });

                    file.share().then(function(resut){
                      luna.debug("file.share: " + resut)
                    },function(error){
                      luna.debug("file.share: " + error)
                    });


                  }, function(error){
                    luna.debug("file.onDownloaded1: " + error)
                  });

                  file.download({
                    isOverwrite   : true,
                  }).then(function(resut){
                    luna.debug("file.download1: " + resut)
                  },function(error){
                    luna.debug("file.download1: " + error)
                  });


                }, function(error){
                  luna.debug("luna.getFile1: " + error)
                })






                luna.getImageFile({
                  path    : "https://lumiere-a.akamaihd.net/v1/images/image_ccc4b657.jpeg"
                }).then( function(file){

                  luna.debug("luna.getFile: " + file.getFilePath())

                  file.onDownload().then( function(result){
                    luna.debug("file.onDownload: " + result)
                  }, function(error){
                    luna.debug("file.onDownload: " + error)
                  });

                  file.onDownloading(function(progress){
                    luna.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    luna.debug( "file.onDownloading: " + result );
                  }, function(error){
                    luna.debug( "file.onDownloading: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    luna.debug("file.onDownloaded: ")
                    luna.debug(result)

                    file.getResizedDOM({quality:10}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: " );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                  }, function(error){
                    luna.debug("file.onDownloaded: " + error)
                  });

                  file.download({
                    isOverwrite   : true
                  }).then(function(resut){
                    luna.debug("file.download: " + resut)
                  },function(error){
                    luna.debug("file.download: " + error)
                  });

                }, function(error){
                  luna.debug("luna.getFile: " + error)
                })





              });



              utility.getElement( "show", "id" ).addEventListener( "click", function() {

                luna.getHtmlFile({
                    filename:   "subindex.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    luna.debug( "luna.getHtmlFile: " );
                    luna.debug( html_file )

                    luna.getNewWebview({
                      html_file: html_file,
                      property: {
                        frame: {
                          height:   320,
                          y:        0
                        },
                        opacity:    0
                      }
                    }).then( function( result ){

                      webview = result;

                      luna.debug( "luna.getNewWebview: " + webview.getID() );

                      webview.load().then(function(result){
                        luna.debug( "webview.load: " + result );
                      });

                      webview.onLoad().then(function(result){
                        luna.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        luna.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        luna.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        luna.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {frame: {
                            height:   320,
                            y:        100
                          },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          luna.debug( "webview.setProperty: " + result );
                        });

                      });

                    },function( error ){
                      luna.debug( error )
                    });


                }, function(error){
                    luna.debug( error )
                })

              });


              utility.getElement( "unzip", "id" ).addEventListener( "click", function() {

                luna.getZipFile({
                  path    : "https://s3.amazonaws.com/data.openaddresses.io/runs/176076/br/am/statewide.zip"
                }).then( function(file){

                  luna.debug("luna.getFile: " )
                  luna.debug(file)

                  file.onDownload().then( function(result){
                    luna.debug("file.onDownload: " + result)
                  }, function(error){
                    luna.debug("file.onDownload: " + error)
                  });

                  file.onDownloading(function(progress){
                    luna.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    luna.debug( "file.onDownloading: " + result );
                  }, function(error){
                    luna.debug( "file.onDownloading: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    luna.debug("file.onDownloaded: ")
                    luna.debug(file)

                    file.onUnzip().then(function(result){
                      luna.debug("file.onUnzip: " + result)
                    }, function(error){
                      luna.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      luna.debug("file.onUnzipped: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      luna.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      luna.debug("file.onUnzipping: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      luna.debug("file.unzip: " + result)
                    }, function(error){
                      luna.debug("file.unzip: " + error)
                    })

                  }, function(error){
                    luna.debug("file.onDownloaded: " + error)
                  });

                  file.download({
                    isOverwrite   : true,
                  }).then(function(resut){
                    luna.debug("file.download: " + resut)
                  },function(error){
                    luna.debug("file.download: " + error)
                  });

                }, function(error){
                  luna.debug("luna.getFile: " + error)
                })


                luna.getZipFile({
                    filename:   "imagefiles.zip" //myfolder.zip imagefiles.zip
                }).then( function( file ){
                    luna.debug( "luna.getZipFile: ");
                    luna.debug(file)

                    file.onUnzip().then(function(result){
                      luna.debug("file.onUnzip: " + result)
                    }, function(error){
                      luna.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      luna.debug("file.onUnzipped: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      luna.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      luna.debug("file.onUnzipping: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      luna.debug("file.unzip: " + result)
                    }, function(error){
                      luna.debug("file.unzip: " + error)
                    })

                });

                luna.getZipFile({
                    filename:   "myfolder.zip" //myfolder.zip imagefiles.zip
                }).then( function( file ){
                    luna.debug( "luna.getZipFile: ");
                    luna.debug(file)

                    file.onUnzip().then(function(result){
                      luna.debug("file.onUnzip: " + result)
                    }, function(error){
                      luna.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      luna.debug("file.onUnzipped: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      luna.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      luna.debug("file.onUnzipping: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      luna.debug("file.unzip: " + result)
                    }, function(error){
                      luna.debug("file.unzip: " + error)
                    })

                });
              });

              utility.getElement( "zip", "id" ).addEventListener( "click", function() {
                luna.getImageFile({
                  filename: "spiderman.jpg",
                  path_type: "document"
                }).then(function(file){

                  file.zip({
                    filename    : "spiderman.zip",
                    isOverwrite : true
                  }).then(function(result){
                    luna.debug("file.zip: " + result)
                  }, function(error){
                    luna.debug("file.zip: " + error)
                  })

                  file.onZip().then(function(result){
                    luna.debug("file.onZip: " + result)
                  }, function(error){
                    luna.debug("file.onZip: " + error)
                  })
                  file.onZipped().then(function(zipFile){
                    luna.debug("file.onZipped: ")
                    luna.debug( zipFile.toJSON() )
                  }, function(error){
                    luna.debug("file.onZipped: " + error)
                  })
                  file.onZipping(function(progress){
                    luna.debug("file.onZipping: " + progress)
                  }).then(function(result){
                    luna.debug("file.onZipping: " + result)
                  }, function(error){
                    luna.debug("file.onZipping: " + error)
                  });

                },function(error){
                  luna.debug("luna.getImageFile: " + error)
                });
              });



              utility.getElement( "filecol", "id" ).addEventListener( "click", function() {

                var listFiles = function( path ) {
                  luna.getFileCollection({
                    path: path,
                    path_type: "document"
                  }).then(function( fileCollection ){
                    luna.debug("luna.getFileCollection: ")
                    luna.debug( "No of Files: " + fileCollection.getFiles().length )

                    utility.forEvery( fileCollection.getFiles(), function(file){
                      
                      if(file.objectType() === "ImageFile") {
                        file.getResizedDOM({quality:100, height: 150}).then( function( DOM ){
                          luna.debug( "imageFile.getResizedDOM: " );
                          debug.appendChild( DOM );
                        }, function(error){
                          luna.debug( "imageFile.getResizedDOM: " + error );
                        });
                      }

                      if(file.objectType() === "File") {
                        luna.debug( file.toJSON() )
                        if( file.getFilename() === ".DS_Store" ) {
                          file.delete().then(function(result){
                            luna.debug("deleted" + file.getFilename())
                          }, function(error){
                            luna.debug(error)
                          })
                        }
                      }

                      if(file.objectType() === "ZipFile") {
                        file.unzip({
                          to: "unzipfolder"
                        }).then(function(result){
                          luna.debug("file.unzip: " + result)
                        }, function(error){
                          luna.debug("file.unzip: " + error)
                        })

                        file.onUnzip().then(function(result){
                          luna.debug("file.onUnzip: " + result)
                        }, function(error){
                          luna.debug("file.onUnzip: " + error)
                        })
                        file.onUnzipped().then(function(result){
                          luna.debug("file.onUnzipped: " + result)
                        }, function(error){
                          luna.debug("file.onUnzipped: " + error)
                        })
                        file.onUnzipping(function(progress){
                          luna.debug("file.onUnzipping: " + progress)
                        }).then(function(result){
                          luna.debug("file.onUnzipping: " + result)
                        }, function(error){
                          luna.debug("file.onUnzipping: " + error)
                        })
                      }
                    });

                    fileCollection.share({includeSubdirectoryFiles:true}).then(function(resut){
                      luna.debug("fileCollection.share: " + resut)
                    },function(error){
                      luna.debug("fileCollection.share: " + error)
                    });

                    utility.forEvery( fileCollection.getDirectories(), function(directory){
                      //listFiles(directory)
                    });

                  }, function(error){
                    luna.debug("luna.getFileCollection: " + error)
                  });
                };

                //zip3folders
                //zip3files
                listFiles("zip3folders");

                

              });


            };

            


            return {
              init: init,
              activatePage: activatePage
            };
      })();

























 
 })( typeof window !== "undefined" ? window : this, document );

