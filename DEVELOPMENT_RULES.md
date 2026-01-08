# Development Rules & Guidelines

## 1. Styling
- All styles must be defined in the themes (no inline styles)

## 2. Architecture (GetX Pattern)
- All functionalities must be in controllers
- All pages and widgets must extend `GetView<Controller>`, not `StatelessWidget` or `StatefulWidget`

## 3. Organization
- Keep everything organized for faster development
- Follow consistent folder structure

## 4. Data Layer
- All models must be in the `data` folder

## 5. Views & Widgets
- All pages (views) must be professional and clean
- Extract all widgets to `widgets` folder within their respective module
- All functionalities must be delegated to the controller

## 6. Animations
- All widgets must have professional animations using `animate_do` package
