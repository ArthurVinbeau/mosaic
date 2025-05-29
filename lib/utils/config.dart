import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final logger = Logger(
    printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.dateAndTime),
    level: Level.debug);
