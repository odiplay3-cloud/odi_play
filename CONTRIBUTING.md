# Правила работы (Claude + GPT)

- Claude пишет код только в ветке `claude/dev`. GPT проверяет и правит только в `gpt/review`. В `main` напрямую не пишем.
- Закончили задачу: открываем Pull Request в `main`. Merge нажимает владелец.
- Скрипты лежат в `src/` по структуре Roblox (`ServerScriptService`, `StarterPlayer/StarterPlayerScripts`, `ReplicatedStorage`).
- Список задач и статусы: `docs/TASKS.md`. Найденные ошибки: `docs/REVIEW.md`.
- Минимум кода на задачу. Меняем только то, что заказано.
- «Готово» значит проверено: запущено или перечитано, а не просто написано.
