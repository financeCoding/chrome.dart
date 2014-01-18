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
import 'dart:convert';
import 'dart:typed_data';

import 'package:chrome/chrome_app.dart' as chrome;

void main() {
  // command names
  final int A_SYNC = 0x434e5953;
  final int A_CNXN = 0x4e584e43;
  final int A_OPEN = 0x4e45504f;
  final int A_OKAY = 0x59414b4f;
  final int A_CLSE = 0x45534c43;
  final int A_WRTE = 0x45545257;
//
//      // ADB protocol version
  final int A_VERSION = 0x01000000;
  //
  final int MAX_PAYLOAD = 4096;

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


      // TODO: Add the info object stuff.

      // send a connect command
//      private void connect() {
//        AdbMessage message = new AdbMessage();
//        message.set(AdbMessage.A_CNXN, AdbMessage.A_VERSION, AdbMessage.MAX_PAYLOAD, "host::\0");
//        message.write(this);
//    }


//  Send the messageBuffer then send the dataBuffer
//      public boolean write(AdbDevice device) {
//        synchronized (device) {
//            UsbRequest request = device.getOutRequest();
//            request.setClientData(this);
//            if (request.queue(mMessageBuffer, 24)) {
//                int length = getDataLength();
//                if (length > 0) {
//                    request = device.getOutRequest();
//                    request.setClientData(this);
//                    if (request.queue(mDataBuffer, length)) {
//                        return true;
//                    } else {
//                        device.releaseOutRequest(request);
//                        return false;
//                    }
//                }
//                return true;
//            } else {
//                device.releaseOutRequest(request);
//                return false;
//            }
//        }
//    }

      int checksum(ByteData data) {
        int result = 0;

        var buffer = new Uint8List.view(data.buffer);

        for (int i = 0; i < buffer.length; i++) {
            int x = buffer[i];
            // dang, no unsigned ints in java
            if (x < 0) x += 256;
            result += x;
        }
        return result;
      }

//      public AdbMessage() {
//        mMessageBuffer = ByteBuffer.allocate(24);
//        mDataBuffer = ByteBuffer.allocate(MAX_PAYLOAD);
//        mMessageBuffer.order(ByteOrder.LITTLE_ENDIAN);
//        mDataBuffer.order(ByteOrder.LITTLE_ENDIAN);
//    }
//
//    // sets the fields in the command header
//    public void set(int command, int arg0, int arg1, byte[] data) {
//        mMessageBuffer.putInt(0, command);
//        mMessageBuffer.putInt(4, arg0);
//        mMessageBuffer.putInt(8, arg1);
//        mMessageBuffer.putInt(12, (data == null ? 0 : data.length));
//        mMessageBuffer.putInt(16, (data == null ? 0 : checksum(data)));
//        mMessageBuffer.putInt(20, command ^ 0xFFFFFFFF);
//        if (data != null) {
//            mDataBuffer.put(data, 0, data.length);
//        }
//    }
//
//    public void set(int command, int arg0, int arg1) {
//        set(command, arg0, arg1, (byte[])null);
//    }
//    public void set(int command, int arg0, int arg1, String data) {
//        // add trailing zero
//        data += "\0";
//        set(command, arg0, arg1, data.getBytes());
//    }

      ByteData mMessageBuffer = new ByteData(24);
      ByteData mDataBuffer = new ByteData(MAX_PAYLOAD);

      String data = "host::";
      Uint8List dataAsUint8List = new Uint8List.fromList(data.codeUnits);
      Uint8List mDataBufferBuffer = new Uint8List.view(mDataBuffer.buffer);
      for (int i = 0; i < dataAsUint8List.length; i++) {
        mDataBufferBuffer[i] = dataAsUint8List[i];
      }

      //message.set(AdbMessage.A_CNXN, AdbMessage.A_VERSION, AdbMessage.MAX_PAYLOAD, "host::\0");
      mMessageBuffer.setInt32(0, A_CNXN, Endianness.LITTLE_ENDIAN);
      mMessageBuffer.setInt32(4, A_VERSION, Endianness.LITTLE_ENDIAN);
      mMessageBuffer.setInt32(8, MAX_PAYLOAD, Endianness.LITTLE_ENDIAN);
      mMessageBuffer.setInt32(12, data.length, Endianness.LITTLE_ENDIAN);
      mMessageBuffer.setInt32(16, checksum(mDataBuffer), Endianness.LITTLE_ENDIAN);
      mMessageBuffer.setInt32(20, A_CNXN ^ 0xFFFFFFFF, Endianness.LITTLE_ENDIAN);


      chrome.GenericTransferInfo transferInfo = new chrome.GenericTransferInfo();
      transferInfo.direction = outDescriptor.direction;
      transferInfo.endpoint = outDescriptor.address;
//      transferInfo.data = new chrome.ArrayBuffer.fromString("hello world\0");
//      transferInfo.length = "hello world\0".length;
      chrome.ArrayBuffer ab = new chrome.ArrayBuffer.fromBytes(new Uint8List.view(mMessageBuffer.buffer).toList());
      print("ab.getBytes().length = ${ab.getBytes().length}");
      transferInfo.length = ab.getBytes().length;
      transferInfo.data = ab;

      chrome.usb.bulkTransfer(connectionHandle, transferInfo).then((chrome.TransferResultInfo result) {
        print("result = ${result}");
        print("result.resultCode = ${result.resultCode}");
        print("result.data = ${result.data}");
        print("result.data.getBytes() = ${result.data.getBytes()}");
        print(UTF8.decode(result.data.getBytes(), allowMalformed: true));

        chrome.ArrayBuffer abData = new chrome.ArrayBuffer.fromBytes(new Uint8List.view(mDataBuffer.buffer).toList());
        chrome.GenericTransferInfo transferInfoData = new chrome.GenericTransferInfo();
        transferInfoData.direction = outDescriptor.direction;
        transferInfoData.endpoint = outDescriptor.address;

        print("abData.getBytes().length = ${abData.getBytes().length}");
        transferInfoData.length = abData.getBytes().length;
        transferInfoData.data = abData;
        chrome.usb.bulkTransfer(connectionHandle, transferInfoData).then((chrome.TransferResultInfo resultData) {
          print("resultData = ${resultData}");
          print("resultData.resultCode = ${resultData.resultCode}");
          print("resultData.data = ${resultData.data}");
          print("resultData.data.getBytes() = ${resultData.data.getBytes().map((int e) => '0x${e.toRadixString(16)}')}");
          print(UTF8.decode(resultData.data.getBytes(), allowMalformed: true));
        });
      });

    });
  });

  ButtonElement readitButton = querySelector("#readit");
  readitButton.onClick.listen((e) {
    chrome.GenericTransferInfo transferInfo = new chrome.GenericTransferInfo();
    transferInfo.direction = inDescriptor.direction;
    transferInfo.endpoint = inDescriptor.address;
    transferInfo.length = 24;
    chrome.usb.bulkTransfer(connectionHandle, transferInfo).then((chrome.TransferResultInfo result) {
      print("result = ${result}");
      print("result.resultCode = ${result.resultCode}");
      print("result.data = ${result.data}");
      print("result.data.getBytes() = ${result.data.getBytes()}");
      print(UTF8.decode(result.data.getBytes(), allowMalformed: true));
    });
  });
}