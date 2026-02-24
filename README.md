# PrintFlow — Застосунок для керування замовленнями

Мобільний та десктопний застосунок для управління замовленнями, побудований на Flutter.

## Функціональність

- 📊 **Дашборд** — огляд статистики, виручки та останніх замовлень
- 📋 **Замовлення** — список, пошук, фільтрація по статусу, прострочені
- 👥 **Клієнти** — база клієнтів, контакти, пов'язані замовлення
- ➕ **Створення замовлень** — мультирядкові позиції, знижки, дедлайни
- 💾 **Локальне сховище** — дані зберігаються локально через Hive

## Статуси замовлень

| Статус | Опис |
|---|---|
| Новий | Щойно створено |
| В роботі | В процесі виконання |
| Готовий | Готовий до видачі |
| Виконано | Завершено та оплачено |
| Скасовано | Відмінено |

## Встановлення та запуск

```bash
# Встановити залежності
flutter pub get

# Запустити на Windows
flutter run -d windows

# Запустити у браузері
flutter run -d chrome

# Запустити на Android
flutter run -d android
```

## Структура проекту

```
lib/
├── main.dart                 # Точка входу
├── models/
│   ├── order.dart            # Модель замовлення
│   ├── client.dart           # Модель клієнта
│   └── order_item.dart       # Модель позиції
├── providers/
│   ├── order_provider.dart   # Стан замовлень
│   └── client_provider.dart  # Стан клієнтів
├── screens/
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── orders_list_screen.dart
│   ├── order_detail_screen.dart
│   ├── order_form_screen.dart
│   ├── clients_list_screen.dart
│   ├── client_detail_screen.dart
│   └── client_form_screen.dart
├── widgets/
│   ├── order_card.dart
│   └── stat_card.dart
└── theme/
    └── app_theme.dart
```

## Залежності

- `provider` — управління станом
- `hive` + `hive_flutter` — локальна БД
- `google_fonts` — шрифт Inter
- `intl` — форматування валюти та дат
- `uuid` — генерація унікальних ID
