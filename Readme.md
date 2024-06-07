# Перед первым запуском
Для установки всех зависимостей пропишите в **Terminal**: `make init`
# Добавление package в свой проект
Рекомендуем добавлять данный package на уровень `Library` или `Services`.
> Сразу после добавления появится ошибка `...must be enabled before it can be used.`. Необходимо нажать на нее и выбрать `Trust & Enable` (так как макросы генерируют код, требуется явное подтверждение).
# Макросы
> Корректное поведение объектов, созданных с помощью макросов, при использовании внутри `#Preview` макроса не гарантируется.
>
> *Причина*: привелегированное выполнение развертывания стандартного макроса `#Preview` от Apple.
>
> *Решение*: используйте `PreviewProvider` структуру.
## Генерация файлов
Если необходимо добавить новый макрос, пропишите в **Terminal**: 
`make macro name=<macroName> [group=<macroGroup>]`
- `name` - имя нового макроса
- `group` - имя группы макросов. Является опциональным параметров. В случае, если не указан, используется значение первого параметра как имя группы.

Разрешены только **латинские** буквы.
## Руководство по написанию
В [файле](TechDocs/tech\_guidelines.md) описаны основные принципы по написанию макросов в проекте, а также рассказано про полезные утилиты/сайты.
## Структура директории
```plaintext
VSURF-Support/
├── Sources/
│   ├── SurfCore/
│   │   └── SomeUtil/
│   │       └── SomeUtil.swift
│   └── SurfMacros/
│         Client/
│           └── main.swift
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
- `SurfCore/` - директория для утилит, не являющимися макросами, однако состовляющими ядро архитектуры VSURF.
- `Client/` - директория для comand-line таргета. На нем удобно проверять работу макросов еще до его использования в проекте. Своего рода Playground.
- `Macros/` - директория, содержащая файлы-объявления макросов
- `Файл объявления макроса` (`Router.swift`, `Previews.swift`) - содержит заголовок макроса
- `Implementation/` - директория,. содержащая файлы-реализации макросов
- `Файл реализации макроса` (`RouterMacro.swift`, `PreviewsMacro.swift`) - содержит тело макроса
- `Группа макросов` (`Components/`, `Utils/`) - набор макросов, объединенных одной темой
- `Плагин группы макросов` (`ComponentsPlugin.swift`, `UtilsPlugin.swift`) - файл-плагин, содержащий все макросы данной группы
- `MacrosPlugin.swift` - файл-плагин, содержащий все макросы библиотеки; реализуется за счет использования плагинов групп.

# Code Snippets
По пути `/Sources/.codesnippets/` можно найти code snippet'ы, используемые в проекте. Для установки перенесите в `~/Library/Developer/Xcode/UserData/CodeSnippets/` файлы с необходимыми snippet'ами, после чего перезапустите Xcode.
## Существующие snippets
- **Previews**

Разворачивается в структуру `PreviewProvider` (`SwiftUI`) для открытия Canvas. Был добавлен как временное решение, пока Apple не поправят макрос `#Preview`.  
