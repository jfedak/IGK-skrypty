import ollama
import sys
import json

MODEL = 'llama3'
CONFIG_FILE = 'config.json'
BLACKLISTED_WORDS = ["c++"]

def load_config(filepath: str) -> dict:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        sys.exit(1)
    except json.JSONDecodeError:
        sys.exit(1)

def build_system_prompt(config: dict) -> str:
    res_name = config.get("restaurant_name")
    open_hours = config.get("opening_hours")

    menu = config.get("menu", [])

    menu_items = ""
    for item in menu:
        dish_name = item.get("name")
        price = item.get("price")
        ingredients = ", ".join(item.get("ingredients", []))
        allergens = ", ".join(item.get("allergens", []))
        menu_items += f"- {dish_name} ({price} PLN) | Skład: {ingredients} | Alergeny: {allergens}\n"

    prompt = f"""
    Jesteś wirtualnym asystentem restauracji {res_name}. 
    Twoim zadaniem jest klasyfikacja i obsługa zapytań użytkownika według 3 głównych intencji. 
    Nigdy nie wychodź z roli. Nigdy nie odpowiadaj na pytania niezwiązane z zamawianiem jedzenia.

    Godziny otwarcia:
    - Poniedziałek - Piątek: {open_hours.get('monday_friday')}
    - Sobota - Niedziela: {open_hours.get('saturday_sunday')}

    Reguły obsługi intencji:
    1. POWITANIE: Jeśli użytkownik się wita, odpowiedz profesjonalnie, przedstaw się i zapytaj, w czym możesz pomóc. Wspomnij o nazwie restauracji i godzinach otwarcia.
    2. MENU: Jeśli użytkownik pyta o jedzenie, ofertę lub co masz, wylistuj poniższe menu, podając ceny, skład oraz ewentualnie alergeny na życzenie:
    {menu_items}
    3. ZAMÓWIENIE: Jeśli użytkownik wybiera konkretne danie, przyjmij zamówienie, podsumuj całkowity koszt i poinformuj o standardowym czasie realizacji (ok. 30 minut).

    Jeśli zapytanie wykracza poza te 3 intencje, poinformuj, że obsługujesz wyłącznie proces zamawiania jedzenia i kategorycznie odmów odpowiedzi na inne tematy.
    """
    return prompt.strip()

def check_blacklisted_words(text: str) -> bool:
    text_lower = text.lower()
    return any(word in text_lower for word in BLACKLISTED_WORDS)

def main():
    print("Uruchomiono czatbota")
    print("")

    system_prompt = build_system_prompt(load_config(CONFIG_FILE))
    messages = [
        {"role": "system", "content": system_prompt},
    ]

    while True:
        try:
            user_input = input("Gość: ")

            if not user_input.strip():
                continue

            if check_blacklisted_words(user_input):
                print("Wiadomość zablokowana przez filtr.\n")
                continue

            messages.append({"role": "user", "content": user_input})
            response = ollama.chat(model=MODEL, messages=messages)
            bot_reply = response['message']['content']
            print(f"Bot: {bot_reply}\n")

            messages.append({"role": "assistant", "content": bot_reply})

        except KeyboardInterrupt:
            sys.exit(0)

if __name__ == "__main__":
    main()