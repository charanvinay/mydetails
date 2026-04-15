import 'package:flutter/material.dart';

import '../models/detail_models.dart';

const List<DetailSection> demoSections = [
  DetailSection(
    type: DetailSectionType.passwords,
    title: 'Passwords',
    icon: Icons.password_rounded,
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    items: [
      DetailItem(
        title: 'Google',
        subtitle: 'chanay@example.com',
        trailing: '••••••••',
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
    colors: [Color(0xFFEA580C), Color(0xFFEF4444)],
    items: [
      DetailItem(
        title: 'HDFC Platinum',
        subtitle: '•••• 4821',
        trailing: 'Exp 2028',
        details: {
          'card_number': '•••• 4821',
          'card_name': 'HDFC Platinum',
          'expiry_year': '2028',
          'cvv': '123',
        },
      ),
      DetailItem(
        title: 'ICICI Coral',
        subtitle: '•••• 1944',
        trailing: 'Exp 2027',
        details: {
          'card_number': '•••• 1944',
          'card_name': 'ICICI Coral',
          'expiry_year': '2027',
          'cvv': '456',
        },
      ),
      DetailItem(
        title: 'Axis Rewards',
        subtitle: '•••• 7710',
        trailing: 'Exp 2029',
        details: {
          'card_number': '•••• 7710',
          'card_name': 'Axis Rewards',
          'expiry_year': '2029',
          'cvv': '789',
        },
      ),
    ],
  ),
  DetailSection(
    type: DetailSectionType.addresses,
    title: 'Addresses',
    icon: Icons.home_rounded,
    colors: [Color(0xFF059669), Color(0xFF14B8A6)],
    items: [
      DetailItem(
        title: 'Home',
        subtitle: 'Whitefield, Bengaluru',
        trailing: '560066',
        details: {
          'label': 'Home',
          'address_line': 'Whitefield, Bengaluru',
          'city': 'Bengaluru',
          'postal_code': '560066',
        },
      ),
      DetailItem(
        title: 'Office',
        subtitle: 'Koramangala, Bengaluru',
        trailing: '560034',
        details: {
          'label': 'Office',
          'address_line': 'Koramangala, Bengaluru',
          'city': 'Bengaluru',
          'postal_code': '560034',
        },
      ),
      DetailItem(
        title: 'Parents',
        subtitle: 'Mysuru, Karnataka',
        trailing: '570001',
        details: {
          'label': 'Parents',
          'address_line': 'Mysuru, Karnataka',
          'city': 'Mysuru',
          'postal_code': '570001',
        },
      ),
    ],
  ),
];
