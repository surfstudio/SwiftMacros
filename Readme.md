# Перед первым запуском
Для установки всех зависимостей пропишите в **Terminal**: `make init`
# Добавление package в свой проект
Рекомендуем добавлять данный package на уровень `Library` или `Services`.
> Сразу после добавления появится ошибка `...must be enabled before it can be used.`. Необходимо нажать на нее и выбрать `Trust & Enable` (так как макросы генерируют код, требуется явное подтверждение).
# Макросы
## Генерация файлов
Если необходимо добавить новый макрос, пропишите в **Terminal**: 
`make macro name=<macroName> [group=<macroGroup>]`
- `name` - имя нового макроса
- `group` - имя группы макросов. Является опциональным параметров. В случае, если не указан, используется значение первого параметра как имя группы.

При вызове значения можно задавать в любом регистре, при генерации он все равно будет изменен на подходящий.
## Структура директории
```plaintext
VSURF-Support/
├── Sources/
│   └── SurfMacros/
│       ├── Macros/
│       │   ├── Components/
│       │   │   └── Router.swift
│       │   └── Utils/
│       │       └── Previews.swift
│       └── Implementation/
│           ├── Components/
│           │   ├── RouterMacro.swift
│           │   └── ComponentsPlugin.swift
│           ├── Utils/
│           │   ├── PreviewsMacro.swift
│           │   └── UtilsPlugin.swift
│           └── MacrosPlugin.swift
└── Tests/
    └── SurfMacros/
        ├── Components/
        │   └── RouterMacroTests.swift
        └── Utils/
            └── PreviewsMacroTests.swift
```
- `Macros/` - директория, содержащая файлы-объявления макросов
- `Файл объявления макроса` (`Router.swift`, `Previews.swift`) - содержит заголовок макроса
- `Implementation/` - директория,. содержащая файлы-реализации макросов
- `Файл реализации макроса` (`RouterMacro.swift`, `PreviewsMacro.swift`) - содержит тело макроса
- `Группа макросов` (`Components/`, `Utils/`) - набор макросов, объединенных одной темой
- `Плагин группы макросов` (`ComponentsPlugin.swift`, `UtilsPlugin.swift`) - файл-плагин, содержащий все макросы данной группы
- `MacrosPlugin.swift` - файл-плагин, содержащий все макросы библиотеки; реализуется за счет использования плагинов групп.


