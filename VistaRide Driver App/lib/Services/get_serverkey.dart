import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getserertoken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "vistafeedd",
          "private_key_id": "80450a81b0d3cf9836dcc0d90720ba72cd4cf63b",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDeTjuarO4cg/kG\nRdHcgzNljl1W7uKnhgpKPu9CEpjFOKhhVgQkxUJsfw4YZ/eRo/XFYR7ofYt/xz1V\nVYvPZmuMqHW+WHU1FlvdaTQKNuUM1L8CIbpqFCDv8SV9Fd4GWXZ+wMwbhFxS4/zk\n5tAjnqEbfpSEoNKdg+BGQYu6nY5HLlYGMlz3+Yqd+H/nocazi2LB1i2HUNu/8eKo\nZzhiT71OUjDT15B+UPX+K8Ehl9RkNVgpZ6iX56hRd1bs8I/ckfu7MHTscGWNI2BP\ntuA5rGu4P0M2xNqSJIDxP6/b3ywxAAvKm0uYUStmmly8T80ANi4TXx/pJXtLidmE\nh5jVwhQnAgMBAAECggEAY4gWcrHTaEwETnUrOXY6qFEd5GLPcx7183kLCYOnB8JO\nzUnEUCxLiaU3S+EcvIXy750EyCYRs7Oid9b14nWiWJdCJGeZjpvEpLTKGnqqgdys\n6ojsXDtH5fYLiV4liqU6gxTSLc3MwkYWf+wBq7kFu/goCduxgNm/K+WD6JlLTv2P\nweb1VP2jUtVnzceS3/VsJShkN+eOI8sLXshyIkyDjFCwe9mSUNzUgsCkOHYHYjbh\nsYEqOKQ1EcqIUDIlqz/1REpld5VLADKfHEmH2DWU+Fjb7yK8DI3RmYOSSY3ZbgqW\nt2/F7n0K60TLVRBVjo/dtbb0kbBe2H+nu/Aewn6WNQKBgQD29nqIkEmXhHBvyXmH\n4Xjnx5buhx7FSOtCO+hNstrGIcEAqb604ob7OvbogSN3y1b05oaesG5J+3iOqiS8\nRsOdR3VGl2KQDNCswCFMIyQ8SXTLJ/s/7NzFr2RGnlA532SdNi2tRy7QUOr1f/8P\nIrXCFTsiSQxHDGtOYNVvj7Z0tQKBgQDmcMSfSTwKkIy89UrhaBaSP+LVGYHuF+sB\n9zsSLwIrVdUJTPSedpB+nse2CZQrHAFKhPkcstSvvYUS7Y7HFXQwAldYADf5CnC2\nDpCBBdV2HYTU4NV3xWaY+t9ngNCRgOGF0COa2dtWu5kW4AM6NVhtGH75/qWaghNp\nz5RaImpq6wKBgQDtn/4I9uSIkNtrBG4Wi6G9SzNz8blu1JnhUilU0bplmEbP74Rb\nIfgFNhgrYU6STqot3L49ZL/KGdhHVXkhW+mOpRo3wSQKPPpwrjGbw9hy1a82ZxL+\n0FchM4EF3gCNnuB90IqkxvBJawKZE/6EPr6qr6kFdUoF9vItKUlVHe/OXQKBgQCX\nwyKq6JdDOemGNGGJS3y5+psPzwmz3Uqnc8QSeKUMFy4DPwxHJDyLN1S9fVd4gKwV\nALfy/4904fK3AX6rfGSVjaUqTpKOUCLks3jVkBsB+/TUIfJUO8wS6f2hc8NoYCGm\nd+pK/DkoyMnMt+FIP4Op7Z0KVXuI4yuX3t6L8eh12wKBgQDYbdDTaZhnofPQ9mr9\niyJiRyVzVwzcT0+cqj/LbjW9t+fQckZeqHy5y1C1r2XH9PfhEfJIjizxHkGnPXVI\nUjKEblzMLcMSKITxfOTIGIL2LOxDQdeC5KBtOKbAbGNodPUEttnuemfp0FYexokE\nKxQ8s5pjdtjcaaQGPZYajcxBSQ==\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-q96rz@vistafeedd.iam.gserviceaccount.com",
          "client_id": "106788002099862085959",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-q96rz%40vistafeedd.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerkey=client.credentials.accessToken.data;
    return accessServerkey;
  }
}
