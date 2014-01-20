// k: RSA key, msg: message to sign
function doAdbSign(k, msg) {
  var rsa = new RSAKey();
  rsa.readPrivateKeyFromPEMString(k);
  var hashAlg = "sha1";
  var hSig = rsa.signString(msg, hashAlg);
  // document.form1.siggenerated.value = linebrk(hSig, 64);
  return hSig;
}

function getHexStringPublicKey(k) {
  var x509 = new X509();
  x509.readCertPEM(k);
  return x509.hex;
}