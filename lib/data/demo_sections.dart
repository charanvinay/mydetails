import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/detail_models.dart';

final List<DetailSection> demoSections = [
  DetailSection(
    type: DetailSectionType.passwords,
    title: 'Passwords',
    icon: Icons.key_rounded,
    colors: [Color(0xFF03346E), Color(0xFF1E40AF)],
    items: [
      DetailItem(
        title: 'Google',
        subtitle: 'chanay@example.com',
        trailing: '••••••••',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/3840px-Google_%22G%22_logo.svg.png',
        details: {
          'app_name': 'Google',
          'username': 'chanay@example.com',
          'password': '••••••••',
        },
      ),
      DetailItem(
        title: 'Netflix',
        subtitle: 'chanay.stream@example.com',
        trailing: '••••••••',
        imageUrl:
            'https://cdn4.iconfinder.com/data/icons/logos-and-brands/512/227_Netflix_logo-512.png',
        details: {
          'app_name': 'Netflix',
          'username': 'chanay.stream@example.com',
          'password': '••••••••',
        },
      ),
      DetailItem(
        title: 'GitHub',
        subtitle: 'chanay-dev',
        trailing: '••••••••',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/25/25231.png',
        details: {
          'app_name': 'GitHub',
          'username': 'chanay-dev',
          'password': '••••••••',
        },
      ),
      DetailItem(
        title: 'Amazon',
        subtitle: 'chanay.shop@example.com',
        trailing: '••••••••',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Amazon_icon.svg/2500px-Amazon_icon.svg.png',
        details: {
          'app_name': 'Amazon',
          'username': 'chanay.shop@example.com',
          'password': '••••••••',
        },
      ),
    ],
  ),
  DetailSection(
    type: DetailSectionType.cards,
    title: 'Cards',
    icon: Icons.credit_card_rounded,
    colors: [Color(0xFFF97316), Color(0xFFEC4899)],
    items: [
      DetailItem(
        title: 'Visa',
        subtitle: '•••• 4821',
        trailing: 'Exp 2028',
        imageUrl:
            'https://download.logo.wine/logo/Visa_Inc./Visa_Inc.-Logo.wine.png',
        details: {
          'card_number': '•••• 4821',
          'card_name': 'Visa',
          'expiry_year': '2028',
          'cvv': '123',
        },
      ),
      DetailItem(
        title: 'Mastercard',
        subtitle: '•••• 1944',
        trailing: 'Exp 2027',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
        details: {
          'card_number': '•••• 1944',
          'card_name': 'Mastercard',
          'expiry_year': '2027',
          'cvv': '456',
        },
      ),
    ],
  ),
  DetailSection(
    type: DetailSectionType.addresses,
    title: 'Addresses',
    icon: Icons.location_on_rounded,
    colors: [Color(0xFF10B981), Color(0xFF0F766E)],
    items: [
      DetailItem(
        title: 'Home',
        subtitle: 'Whitefield, Bengaluru',
        trailing: '560066',
        icon: Icons.home_rounded,
        colors: [Color(0xFF0F172A), Color(0xFF0F172A)],
        details: {
          'label': 'Home',
          'address_line': 'Whitefield, Bengaluru',
          'city': 'Bengaluru',
          'postal_code': '560066',
        },
      ),
    ],
  ),
];
