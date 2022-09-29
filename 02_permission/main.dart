import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('this is demo')),
      body: Center(
        child: ListView(
          children: _getPermissions(),
        ),
      ),
    );
  }

  _getPermissions() {
    return Permission.values
        .where((permission) {
          if (Platform.isAndroid) {
            return permission != Permission.unknown &&
                permission != Permission.mediaLibrary &&
                permission != Permission.photos &&
                permission != Permission.photosAddOnly &&
                permission != Permission.reminders &&
                permission != Permission.appTrackingTransparency &&
                permission != Permission.criticalAlerts;
          }

          return permission != Permission.unknown &&
              permission != Permission.sms &&
              permission != Permission.storage &&
              permission != Permission.ignoreBatteryOptimizations &&
              permission != Permission.accessMediaLocation &&
              permission != Permission.activityRecognition &&
              permission != Permission.manageExternalStorage &&
              permission != Permission.systemAlertWindow &&
              permission != Permission.requestInstallPackages &&
              permission != Permission.accessNotificationPolicy &&
              permission != Permission.bluetoothScan &&
              permission != Permission.bluetoothAdvertise &&
              permission != Permission.bluetoothConnect;
        })
        .map((permission) => PermissionWidget(permission))
        .toList();
  }
}

class PermissionWidget extends StatefulWidget {
  final Permission _permission;

  const PermissionWidget(this._permission, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PermissionState();
}

class PermissionState extends State<PermissionWidget> {
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenPermissionStatus();
  }

  _listenPermissionStatus() async {
    _permissionStatus = await widget._permission.status;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget._permission.toString()),
      subtitle: Text(_permissionStatus.name.toString()),
      trailing: (widget._permission is PermissionWithService)
          ? IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _checkServiceStatus(
                    widget._permission as PermissionWithService);
              },
            )
          : null,
      onTap: () {
        _requestPermission(widget._permission);
      },
    );
  }

  // 检查服务状态
  _checkServiceStatus(PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((await permission.serviceStatus).toString()),
      ),
    );
  }

  // 请求权限
  _requestPermission(Permission permission) async {
    final status = await permission.request();
    _permissionStatus = status;
    setState(() {});
  }
}
