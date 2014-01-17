// system/core/adb/usb_osx.c::AndroidInterfaceAdded():INFO: Found vid=18d1 pid=4ee2 serial=0301207d08e43206
//; 0x20
//  32
//; 0x18d1
//  6353
//; 0x4ee2
//  20194
//; 0x0301207d08e43206
//  216489978482668038
//;

import 'dart:async';
import 'dart:html';

import 'package:chrome/chrome_app.dart' as chrome;

void main() {
  chrome.Device androidDevice;
  chrome.InterfaceDescriptor adbInterface;
  chrome.EndpointDescriptor inDescriptor;
  chrome.EndpointDescriptor outDescriptor;
  chrome.ConnectionHandle connectionHandle;

  window.onKeyUp.listen((KeyboardEvent event) {
    if (event.keyCode == KeyCode.R) {
      chrome.runtime.reload();
    }
  });

  print("hello world");
  ButtonElement be = querySelector("#clickit");
  be.onClick.listen((e) {
    //"vendorId": 6353, "productId": 20194
    chrome.EnumerateDevicesOptions o =
        new chrome.EnumerateDevicesOptions(vendorId: 6353,  productId: 20194);

    chrome.usb.getDevices(o).then((List<chrome.Device> devices){
      print("devices = ${devices}");
      devices.forEach((chrome.Device d){
        print("d.device = ${d.device}");
        print("d.productId = ${d.productId}");
        print("d.vendorId = ${d.vendorId}");

        var options = new chrome.EnumerateDevicesAndRequestAccessOptions(
            vendorId: d.vendorId, productId: d.productId);

        chrome.usb.findDevices(options).then((List<chrome.ConnectionHandle> connections) {
          print("connections = ${connections}");
          connections.forEach((chrome.ConnectionHandle ch) {
            print("ch = $ch");
            print("ch.handle = ${ch.handle}");
            print("ch.productId = ${ch.productId}");
            print("ch.vendorId = ${ch.vendorId}");

            chrome.usb.listInterfaces(ch).then((List<chrome.InterfaceDescriptor> interfaces) {
              print("interfaces = ${interfaces}");
              interfaces.forEach((chrome.InterfaceDescriptor i) {
                print("i = ${i}");
                print("i.interfaceNumber = ${i.interfaceNumber}");
                print("i.alternateSetting = ${i.alternateSetting}");
                print("i.interfaceClass = ${i.interfaceClass}");
                print("i.interfaceSubclass = ${i.interfaceSubclass}");
                print("i.interfaceProtocol = ${i.interfaceProtocol}");
                print("i.description = ${i.description}");
                print("i.endpoints = ${i.endpoints}");

//                #define ADB_CLASS              0xff
//                #define ADB_SUBCLASS           0x42
//                #define ADB_PROTOCOL           0x1
                //* check to make sure interface class, subclass and protocol match ADB
                //* avoid opening mass storage endpoints
                if (i.interfaceClass == 0xff && i.interfaceSubclass == 0x42 && i.interfaceProtocol == 0x1) {
                  print("device found.");
                  adbInterface = i;
                  androidDevice = d;
                  connectionHandle = ch;
                }

                i.endpoints.forEach((chrome.EndpointDescriptor des) {
                  print("des = ${des}");
                  print("des.address = ${des.address}");
                  print("des.type = ${des.type}");
                  print("des.direction = ${des.direction}");
                  print("des.maximumPacketSize = ${des.maximumPacketSize}");
                  //print("des.synchronization = ${des.synchronization}");
                  print("des.usage = ${des.usage}");
                  print("des.pollingInterval = ${des.pollingInterval}");
                  print("");

                  if (des.direction == chrome.Direction.IN && i.interfaceClass == 0xff && i.interfaceSubclass == 0x42 && i.interfaceProtocol == 0x1) {
                    print("device found.");
                    inDescriptor = des;
                  } else if (des.direction == chrome.Direction.OUT && i.interfaceClass == 0xff && i.interfaceSubclass == 0x42 && i.interfaceProtocol == 0x1) {
                    outDescriptor = des;



                  }
                });
              });

              // Check that inDescriptor and outDescriptor not null and try to open device
              if (inDescriptor == null || outDescriptor == null) {
                throw "Could not find device";
              }

              // chrome.usb.requestAccess(device, interfaceId)
              //return;

            });
          });
        });
      });


    });
  });

  ButtonElement openit = querySelector("#openit");
  openit.onClick.listen((e) {
    print("opening device");
//    chrome.usb.requestAccess(androidDevice, adbInterface.interfaceNumber).then((bool b) {
//      print("requestAccess b = $b");
//    });

    chrome.usb.claimInterface(connectionHandle, adbInterface.interfaceNumber).then((d) {
      print("d = $d");

      chrome.GenericTransferInfo transferInfo = new chrome.GenericTransferInfo();
      // TODO: Add the info object stuff.
      chrome.usb.bulkTransfer(connectionHandle, transferInfo);

    });
  });
}