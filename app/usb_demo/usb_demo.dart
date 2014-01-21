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

// TODO: implement some sync commands.
// TODO: switch out for a simpler crypto implementation

import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:js' as js;

import 'package:chrome/chrome_app.dart' as chrome;

// Private key is in RSA format cause the javascript RSA code expected it
// that way. Key formats stored in ~/.android/adbkey[.pub] are in OpenSSL
// format. Convert to RSA can be done with: openssl rsa -in adbkey -out /tmp/rsa_adbkey
final String privateKey = """-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEApDRpfZFi+knH1F7hJCgAnPTWo7rulm+ZEnSgFu8D7zDsbgI+
Ff/7P7s43Ze4q5O9rScjeqb1Ws6bdtA+Sa1qmkwfa52ih9nhzErgWvmgiA2J6N3+
F7ybRmrn5laS4P3BZlmMlsHyFneGtXn7CFu+5mPNkqKQOraXkdF8iGYZmNMtfeLw
ureS/R7gh0eRaxGeSYwTqCv+LtQwaXlIe6eigXBG82I2kB/MunjK2iJGcdxWTHEd
gS03UbS/KlB1pBftDxbcbiFqBAsfzixfbqXaOP7Pth5YDsAK1OyGEXQxkV/wsGgN
XlcwLuWahpC/1oomVVRWNp57UFtGsNlAg1fciwIDAQABAoIBAE9a5QBCGstKjMAd
ekC29FTmHjTSSit5k0hQBG4Q5J3bzub7PnXzV8DdAgZVJHIG3Eup9oN33GseHhO1
X+TLYhFfaG/hpoJw0aahKPvOV75ojJV1cy6Vf5TwZVHz1NfWynhkHoVdBVnGOdvK
L39Cl2dQJDERTxKQ238k9kIU1Zn87mkzayaSXf1+GrgQnDycO7gI3sTSdayFEL+W
S3U7V+3GXesGnE/5+oqmvvEBgLbWqvcn1Y4YAk27mM2k4DMzAY1NbTh9rrzYHPTT
K9n6IGzFcbckDramGvTmIvmdz7wDXVKcEMbLTSbGWVUCSnMX1X3IJ+XdqrOlDGc1
yBQARgECgYEA0qLkrX05XL8A3EcRiOlOtKSayHG6pQ4+kMjeZqFi0pERwJVcY8B/
QNob3tp8M2k/hzDih7V/HRQhyOOdyMFQrSrXoaRSYuAY+qgkeT2HtQh7fOZBv2i5
7PRKMNy6xfkQZF1TgrMAVtBL725GmJ97ATEddztbruG3a9k40EgA5CECgYEAx5GW
DkPqKXDHoBpbPoXU0lTJy2SaIVTf4OYwnd0PGbXMa/k906m/oPvVkdxW2TjrrtvG
3kyjK9jYrirISkZEuL5tcXH5IS3ZPEIHYFzpKsJo0u/CKqKfWsP6yuTsjsG8CqCZ
hpKKWnv+WPIsisCUFknNbL0CpgMLDmilz6jgKysCgYBSJzhbtiCeXNzgDVP4e064
RA8eqMTsRX7/h2i+zKk3iV9MJrUvLtAzIh6Gr96LSrx9ZQKlfZODauu2Z5iNyWBG
+hO6NtXvPIphkR0QsH/yislnMINqPVVu5uTc4+pw9rB/BKtiqaAzO/CyBOfB9UnL
cDWW4G7k6aJZjRKModi/IQKBgC/jQWye41uaUmyapnZ0SsNF0T5bH5kL8sTWt6fJ
2cvDkg/+uNVHkFIi2/aqNrTdMcC9wBSrsyPcXvI8Fd+syOTD3SMxxCQwCkapWXfI
E7NM/zZOjfsJFtAC4vU4xYLj/ilWrEBcfZKE2l2hjwqkd2R5xS9ok3AentKQTels
jo4NAoGAV9V/3wHro5gpZ9+Fw4pjANX/vfCEzg7zVsDCvEWcEVYi0ETDfuMvCTYU
WRnT/0lpFuueudrw8YH0GKUkZqcBgiGlVsRHI9IwWA5iUoSl8uOFFsONM72kgWKR
oC3DsyC99R6bL4TyVBrj0QBotg9RpxsjkSj4bRN1YSelsFiBW1k=
-----END RSA PRIVATE KEY-----""";

// Android device expects the publicKey for RSAPUBLICKEY(3) to be in OpenSSL format.
// This string came from cat ~/.android/adbkey.pub
final String publicKey =
"""QAAAAN1Ue7aL3FeDQNmwRltQe542VlRVJorWv5CGmuUuMFdeDWiw8F+RMXQRhuzUCsAOWB62z/442qVuXyzOHwsEaiFu3BYP7RekdVAqv7RRNy2BHXFMVtxxRiLayni6zB+QNmLzRnCBoqd7SHlpMNQu/iuoE4xJnhFrkUeH4B79kre68OJ9LdOYGWaIfNGRl7Y6kKKSzWPmvlsI+3m1hncW8sGWjFlmwf3gklbm52pGm7wX/t3oiQ2IoPla4ErM4dmHop1rH0yaaq1JPtB2m85a9aZ6IyetvZOruJfdOLs/+/8VPgJu7DDvA+8WoHQSmW+W7rqj1vScACgk4V7Ux0n6YpF9aTSk50ZpQUz7mZ9DTIgsEVHCSK2zl/mdQW4wPuWS2K1QfcfG7qPStU/5RU6vPoH0gjoTL7de/BRACKbOXcVWZcwdlECzcLM4diKGvUTN6RUdvS0ch8YVBRTVnAm3FIqWTXXbLwe7snfdvBqo5wVXU8MtlXUywqhPXyZ4BjnS8I3wkM8eYT9B8hHW9AWDMfe2o7Lj9T3W/qjoWKh0sWWqdpTiw98mHceWUhp+Fv2NkwKL2a7Z+vMjWm3bz0p7JMksCtO9yi0uWXNuvbFaUjuJ9Q40nYB/35HucKR7SbOhqNwvvWkBb2Xbp/qvuPj5jVkulBvBMz+RxFrRe12nS18ioQCOlAEAAQA= adam.singer@csfol-m0429761""";



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

ByteData stringToByteData(String input) {
  int offset = 0;
  ByteData byteData = new ByteData(input.length~/2);
  for (int j = 0; j < input.length - 1; j+=2) {
    String b = input[j] + input[j+1];
    byteData.setUint8(offset, int.parse(b, radix: 16));
    offset++;
  }

  Uint8List m = new Uint8List.view(byteData.buffer);
  print("stringToByteData ${input} = ${m.map((e) => '0x${e.toRadixString(16)}').toList()}");
  return byteData;
}

void main() {
  // command names
  final int A_SYNC = 0x434e5953;
  final int A_CNXN = 0x4e584e43;
  final int A_OPEN = 0x4e45504f;
  final int A_OKAY = 0x59414b4f;
  final int A_CLSE = 0x45534c43;
  final int A_WRTE = 0x45545257;

  final int A_AUTH = 0x48545541;

//
//      // ADB protocol version
  final int A_VERSION = 0x01000000;
  //
  final int MAX_PAYLOAD = 4096;
  final int ADB_VERSION_MINOR = 0;         // Used for help/version information

  final ADB_SERVER_VERSION   = 31;    // Increment this when we want to force users to start a new adb server

  chrome.Device androidDevice;
  chrome.InterfaceDescriptor adbInterface;
  chrome.EndpointDescriptor inDescriptor;
  chrome.EndpointDescriptor outDescriptor;
  chrome.ConnectionHandle connectionHandle;
  String deviceToken = "DEVICE TOKEN NOT SET";

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
      print("resultData.data.getBytes() = ${result.data.getBytes().map((int e) => '0x${e.toRadixString(16)}').toList()}");
      print(UTF8.decode(result.data.getBytes(), allowMalformed: true));

      // Read back a mMessageBuffer for AUTH response
      ByteData __mMessageBuffer = new ByteData(24);
      ByteData __mDataBuffer = new ByteData(MAX_PAYLOAD);

      var bufList = new Uint8List.fromList(result.data.getBytes());
      Uint8List __mDataBufferBuffer = new Uint8List.view(__mMessageBuffer.buffer);
      for (int i = 0; i < bufList.length; i++) {
        __mDataBufferBuffer[i] = bufList[i];
      }

      int _command = __mMessageBuffer.getInt32(0, Endianness.LITTLE_ENDIAN);
      int _version = __mMessageBuffer.getInt32(4, Endianness.LITTLE_ENDIAN);
      int _max_payload = __mMessageBuffer.getInt32(8, Endianness.LITTLE_ENDIAN);
      int _data_length = __mMessageBuffer.getInt32(12, Endianness.LITTLE_ENDIAN);
      int _checksum = __mMessageBuffer.getInt32(16, Endianness.LITTLE_ENDIAN);
      int _magic = __mMessageBuffer.getInt32(20, Endianness.LITTLE_ENDIAN);

      print("_command = ${_command.toRadixString(16)}");
      print("_version = ${_version.toRadixString(16)}");
      print("_max_payload = ${_max_payload.toRadixString(16)}");
      print("_data_length = ${_data_length.toRadixString(16)}");
      print("_checksum = ${_checksum.toRadixString(16)}");
      print("_magic = ${_magic.toRadixString(16)}");

      // TODO: use the _data_length to readin the random data from
      // the device..

      chrome.GenericTransferInfo readDataTransferInfo = new chrome.GenericTransferInfo();
      readDataTransferInfo.direction = inDescriptor.direction;
      readDataTransferInfo.endpoint = inDescriptor.address;
      readDataTransferInfo.length = _data_length;
      chrome.usb.bulkTransfer(connectionHandle, readDataTransferInfo).then((chrome.TransferResultInfo resultWithToken) {
        print("token data next step... ");
        print("resultWithToken = ${resultWithToken}");
        print("resultWithToken.resultCode = ${resultWithToken.resultCode}");
        print("resultWithToken.data = ${resultWithToken.data}");
        print("resultWithToken.data.getBytes() = ${resultWithToken.data.getBytes()}");
        print("resultWithToken.data.getBytes() = ${resultWithToken.data.getBytes().map((int e) => '0x${e.toRadixString(16)}').toList()}");
        print(UTF8.decode(resultWithToken.data.getBytes(), allowMalformed: true));
        deviceToken = UTF8.decode(resultWithToken.data.getBytes(), allowMalformed: true);
      });
    });
  });

//  static void send_auth_publickey(atransport *t)
//  {
//    D("Calling send_auth_publickey\n");
//    apacket *p = get_apacket();
//    int ret;
//
//    ret = adb_auth_get_userkey(p->data, sizeof(p->data));
//    if (!ret) {
//        D("Failed to get user public key\n");
//        put_apacket(p);
//        return;
//    }
//
//    p->msg.command = A_AUTH;
//    p->msg.arg0 = ADB_AUTH_RSAPUBLICKEY;
//    p->msg.data_length = ret;
//    send_packet(p, t);
//}

  ButtonElement signit = querySelector("#signit");
  signit.onClick.listen((e) {
    var sig  = js.context.callMethod('doAdbSign', [privateKey, deviceToken]);
    print("'${deviceToken}' sig = ${sig}");
    var hexStringPubKey = js.context.callMethod('getHexStringPublicKey', [publicKey]);
    print("hexStringPubKey = ${hexStringPubKey}");


    ByteData mMessageBuffer = new ByteData(24);
    ByteData mDataBuffer = new ByteData(MAX_PAYLOAD);

    String data = hexStringPubKey;
    Uint8List dataAsUint8List = new Uint8List.fromList(data.codeUnits);
    Uint8List mDataBufferBuffer = new Uint8List.view(mDataBuffer.buffer);
    for (int i = 0; i < dataAsUint8List.length; i++) {
      mDataBufferBuffer[i] = dataAsUint8List[i];
    }

    //message.set(AdbMessage.A_CNXN, AdbMessage.A_VERSION, AdbMessage.MAX_PAYLOAD, "host::\0");
    mMessageBuffer.setInt32(0, A_AUTH, Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(4, 2, Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(8, 0, Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(12, data.length, Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(16, checksum(mDataBuffer), Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(20, A_AUTH ^ 0xFFFFFFFF, Endianness.LITTLE_ENDIAN);


    chrome.GenericTransferInfo transferInfo = new chrome.GenericTransferInfo();
    transferInfo.direction = outDescriptor.direction;
    transferInfo.endpoint = outDescriptor.address;
    chrome.ArrayBuffer ab = new chrome.ArrayBuffer.fromBytes(new Uint8List.view(mMessageBuffer.buffer).toList());
    print("ab.getBytes().length = ${ab.getBytes().length}");
    transferInfo.length = ab.getBytes().length;
    transferInfo.data = ab;
    chrome.usb.bulkTransfer(connectionHandle, transferInfo).then((chrome.TransferResultInfo result) {
      print("result = ${result}");
      print("result.resultCode = ${result.resultCode}");
      print("result.data = ${result.data}");
      print("result.data.getBytes() = ${result.data.getBytes()}");
      print("resultData.data.getBytes() = ${result.data.getBytes().map((int e) => '0x${e.toRadixString(16)}').toList()}");
      print(UTF8.decode(result.data.getBytes(), allowMalformed: true));

      // Transfer the signed data
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

        // SEND OVER RSAPUBLICKEY(3)
        ByteData byteDataPubKey = stringToByteData(hexStringPubKey);
        print("byteDataPubKey.buffer.lengthInBytes = ${byteDataPubKey.buffer.lengthInBytes}");
        ByteData mMessageBuffer = new ByteData(24);
        //message.set(AdbMessage.A_CNXN, AdbMessage.A_VERSION, AdbMessage.MAX_PAYLOAD, "host::\0");
        mMessageBuffer.setInt32(0, A_AUTH, Endianness.LITTLE_ENDIAN);
        mMessageBuffer.setInt32(4, 3, Endianness.LITTLE_ENDIAN);
        mMessageBuffer.setInt32(8, 0, Endianness.LITTLE_ENDIAN);
        mMessageBuffer.setInt32(12, byteDataPubKey.buffer.lengthInBytes, Endianness.LITTLE_ENDIAN);
        mMessageBuffer.setInt32(16, checksum(byteDataPubKey), Endianness.LITTLE_ENDIAN);
        mMessageBuffer.setInt32(20, A_AUTH ^ 0xFFFFFFFF, Endianness.LITTLE_ENDIAN);
        chrome.GenericTransferInfo transferInfo = new chrome.GenericTransferInfo();
        transferInfo.direction = outDescriptor.direction;
        transferInfo.endpoint = outDescriptor.address;
        chrome.ArrayBuffer ab = new chrome.ArrayBuffer.fromBytes(new Uint8List.view(mMessageBuffer.buffer).toList());
        print("ab.getBytes().length = ${ab.getBytes().length}");
        transferInfo.length = ab.getBytes().length;
        transferInfo.data = ab;
        chrome.usb.bulkTransfer(connectionHandle, transferInfo).then((chrome.TransferResultInfo result) {
          print("result = ${result}");
          print("result.resultCode = ${result.resultCode}");
          print("result.data = ${result.data}");
          print("result.data.getBytes() = ${result.data.getBytes()}");
          print("resultData.data.getBytes() = ${result.data.getBytes().map((int e) => '0x${e.toRadixString(16)}').toList()}");
          print(UTF8.decode(result.data.getBytes(), allowMalformed: true));

          // Transfer the pubkey
          chrome.ArrayBuffer abData = new chrome.ArrayBuffer.fromBytes(new Uint8List.view(byteDataPubKey.buffer).toList());
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
  });

//  ButtonElement testit = querySelector("#testit");
//  testit.onClick.listen((e) {
//    String i = "QAAAAN1Ue7aL3FeDQNmwRltQe542VlRVJorWv5CGmuUuMFdeDWiw8F+RMXQRhuzUCsAOWB62z/442qVuXyzOHwsEaiFu3BYP7RekdVAqv7RRNy2BHXFMVtxxRiLayni6zB+QNmLzRnCBoqd7SHlpMNQu/iuoE4xJnhFrkUeH4B79kre68OJ9LdOYGWaIfNGRl7Y6kKKSzWPmvlsI+3m1hncW8sGWjFlmwf3gklbm52pGm7wX/t3oiQ2IoPla4ErM4dmHop1rH0yaaq1JPtB2m85a9aZ6IyetvZOruJfdOLs/+/8VPgJu7DDvA+8WoHQSmW+W7rqj1vScACgk4V7Ux0n6YpF9aTSk50ZpQUz7mZ9DTIgsEVHCSK2zl/mdQW4wPuWS2K1QfcfG7qPStU/5RU6vPoH0gjoTL7de/BRACKbOXcVWZcwdlECzcLM4diKGvUTN6RUdvS0ch8YVBRTVnAm3FIqWTXXbLwe7snfdvBqo5wVXU8MtlXUywqhPXyZ4BjnS8I3wkM8eYT9B8hHW9AWDMfe2o7Lj9T3W/qjoWKh0sWWqdpTiw98mHceWUhp+Fv2NkwKL2a7Z+vMjWm3bz0p7JMksCtO9yi0uWXNuvbFaUjuJ9Q40nYB/35HucKR7SbOhqNwvvWkBb2Xbp/qvuPj5jVkulBvBMz+RxFrRe12nS18ioQCOlAEAAQA=";
//    print("i = $i");
//    print("i.length = ${i.length}");
//    print(stringToByteData(i));
////    int offset = 0;
////    ByteData byteData = new ByteData(i.length~/2);
////    for (int j = 0; j < i.length - 1; j+=2) {
////      // dont know if its 32bit aligned.
////      String ii = i[j] + i[j+1]; // + i[j+2] + i[j+3];
////      print(ii);
////      byteData.setUint8(offset, int.parse(ii, radix: 16));
////      offset ++;
////      Uint8List m = new Uint8List.view(byteData.buffer);
////      print("m = ${m.map((e) => '0x${e.toRadixString(16)}').toList()}");
////    }
//
//
//  });

  ButtonElement openurl = querySelector("#openurl");
  openurl.onClick.listen((e) {

//    void connect_to_remote(asocket *s, const char *destination)
//    {
//      D("Connect_to_remote call RS(%d) fd=%d\n", s->id, s->fd);
//      apacket *p = get_apacket();
//      int len = strlen(destination) + 1;
//
//      if(len > (MAX_PAYLOAD-1)) {
//        fatal("destination oversized");
//    }
//
//    D("LS(%d): connect('%s')\n", s->id, destination);
//    p->msg.command = A_OPEN;
//    p->msg.arg0 = s->id;
//    p->msg.data_length = len;
//    strcpy((char*) p->data, destination);
//    send_packet(p, s->transport);
//}
//    system/core/adb/sockets.c::smart_socket_enqueue():SS(0): 'shell:am start -a android.intent.action.VIEW -d http://127.0.0.1:8000'
//      system/core/adb/sockets.c::connect_to_remote():Connect_to_remote call RS(2) fd=11
//      system/core/adb/sockets.c::connect_to_remote():LS(2): connect('shell:am start -a android.intent.action.VIEW -d http://127.0.0.1:8000')
//      system/core/adb/transport.c::dump_packet():0301207d08e43206: to remote: [OPEN] arg0=2 arg1=0 (len=70) 7368656c6c3a616d207374617274202d shell:am start -
//      system/core/adb/sockets.c::smart_socket_close():SS(0): closed
//      system/core/adb/sockets.c::local_socket_event_func():LS(2): fd=11 post peer->enqueue(). r=1
//      system/core/adb/transport.c::dump_packet():0301207d08e43206: from remote: [OPEN] arg0=2 arg1=0 (len=70) 7368656c6c3a616d207374617274202d shell:am start -
//      system/core/adb/transport.c::input_thread():0301207d08e43206: transport got packet, sending to remote
//      system/core/adb/transport.c::output_thread():0301207d08e43206: received remote packet, sending to transport
//      system/core/adb/transport.c::dump_packet():0301207d08e43206: to remote: [OKAY] arg0=0x662 arg1=2 (len=0)


    ByteData mMessageBuffer = new ByteData(24);
    ByteData mDataBuffer = new ByteData(MAX_PAYLOAD);

    String data = "shell:am start -a android.intent.action.VIEW -d http://www.dartlang.org ";
    Uint8List dataAsUint8List = new Uint8List.fromList(data.codeUnits);
    Uint8List mDataBufferBuffer = new Uint8List.view(mDataBuffer.buffer);
    for (int i = 0; i < dataAsUint8List.length; i++) {
      mDataBufferBuffer[i] = dataAsUint8List[i];
    }

    mMessageBuffer.setInt32(0, A_OPEN, Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(4, 2, Endianness.LITTLE_ENDIAN); // local-id
    mMessageBuffer.setInt32(8, 0, Endianness.LITTLE_ENDIAN); // 0
    mMessageBuffer.setInt32(12, data.length, Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(16, checksum(mDataBuffer), Endianness.LITTLE_ENDIAN);
    mMessageBuffer.setInt32(20, A_OPEN ^ 0xFFFFFFFF, Endianness.LITTLE_ENDIAN);

    chrome.GenericTransferInfo transferInfo = new chrome.GenericTransferInfo();
    transferInfo.direction = outDescriptor.direction;
    transferInfo.endpoint = outDescriptor.address;
    chrome.ArrayBuffer ab = new chrome.ArrayBuffer.fromBytes(new Uint8List.view(mMessageBuffer.buffer).toList());
    print("ab.getBytes().length = ${ab.getBytes().length}");
    transferInfo.length = ab.getBytes().length;
    transferInfo.data = ab;
    chrome.usb.bulkTransfer(connectionHandle, transferInfo).then((chrome.TransferResultInfo result) {
      print("result = ${result}");
      print("result.resultCode = ${result.resultCode}");
      print("result.data = ${result.data}");
      print("result.data.getBytes() = ${result.data.getBytes()}");
      print("resultData.data.getBytes() = ${result.data.getBytes().map((int e) => '0x${e.toRadixString(16)}').toList()}");
      print(UTF8.decode(result.data.getBytes(), allowMalformed: true));

      // Transfer the data
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
}
