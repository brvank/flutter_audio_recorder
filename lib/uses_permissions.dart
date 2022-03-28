import 'package:permission_handler/permission_handler.dart';

class UsesPermissions{

  static Future<bool> RequestPermission(Permission permission) async{
    if(await permission.isGranted){
      return true;
    }else{
      var result = await permission.request();
      if(result == PermissionStatus.granted){
        return true;
      }else{
        return false;
      }
    }
  }

}