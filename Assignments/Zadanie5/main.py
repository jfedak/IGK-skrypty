import ollama
import sys
import json
import requests
import re

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

def load_menu_from_flask() -> list:
    try:
        response = requests.get("http://127.0.0.1:5000/menu")
        return response.json()
    except requests.exceptions.RequestException:
        sys.exit(1)

def send_order_to_flask(order_data: dict) -> bool:
    try:
        response = requests.post("http://127.0.0.1:5000/save_order", json=order_data)
        return response.status_code == 201
    except requests.exceptions.RequestException:
        sys.exit(1)

def build_system_prompt(config: dict, menu: list) -> str:
    res_name = config.get("restaurant_name")
    open_hours = config.get("opening_hours")

    menu_items = ""
    for item in menu:
        dish_name = item.get("name")
        price = item.get("price")
        ingredients = ", ".join(item.get("ingredients", []))
        allergens = ", ".join(item.get("allergens", []))
        menu_items += f"- {dish_name} ({price} PLN) | Skład: {ingredients} | Alergeny: {allergens}\n"

    prompt = f"""
    Jesteś wirtualnym asystentem restauracji {res_name}. 
    Twoim zadaniem jest rygorystyczne przestrzeganie poniższego, 4-etapowego przepływu konwersacji. 
    Nidgy nie wychodź z roli. Nigdy nie odpowiadaj na pytania niezwiązane z zamawianiem jedzenia.

    DANE MENU:
    {menu_items}

    GODZINY OTWARCIA:
    - Poniedziałek - Piątek: {open_hours.get('monday_friday')}
    - Sobota - Niedziela: {open_hours.get('saturday_sunday')}

    KROKI KONWERSACJI (musisz wykonywać je po kolei):
    KROK 1. POWITANIE: Jeśli użytkownik się wita, odpowiedz profesjonalnie i zapytaj, w czym możesz pomóc. Poinformuj o nazwie restauracji oraz godzinach otwarcia.
    KROK 2. MENU: Jeśli użytkownik pyta o ofertę, zaprezentuj DANE MENU (podaj nazwy, ceny, skład i alergeny). Zakończ pytaniem, na co ma ochotę.
    KROK 3. ZAPYTANIE O ALERGIE I MODYFIKACJE (KRYTYCZNE): 
    Gdy użytkownik wybierze konkretne dania z menu, ZATRZYMAJ SIĘ. Poinformuj, że zanotowałeś wybór, ale ZANIM podsumujesz zamówienie, MUSISZ zapytać użytkownika: "Czy masz jakieś alergie pokarmowe lub czy chcesz usunąć jakieś składniki z wybranych dań?". 
    NIGDY nie kończ zamówienia w tym kroku. Czekaj na odpowiedź użytkownika.
    KROK 4. ADRES DOSTAWY (KRYTYCZNE): Gdy użytkownik odpowie na pytanie o alergie (nawet jeśli odpowie "nie"), zapytaj o adres dostawy. Aby adres był kompletny, musi zawierać: Miasto, Ulicę oraz Numer domu/mieszkania. Jeśli podano niepełny adres, ZATRZYMAJ SIĘ i dopytaj o braki.
    KROK 5. PODSUMOWANIE ZAMÓWIENIA: 
    Gdy użytkownik odpowie na pytanie o adres, wygeneruj ostateczne podsumowanie zamówienia.
    Podsumowanie MUSI zawierać:
    - Listę wybranych dań.
    - Wyraźną informację o modyfikacjach (np. "bez pomidora") lub "Brak modyfikacji".
    - Całkowity koszt zamówienia w PLN (zsumuj ceny wszystkich dań).
    - Adres dostawy w formacie: Miasto, Ulica, Numer domu/mieszkania.
    - Estymowany czas gotowości do odbioru w restauracji. Oblicz go na podstawie wzoru: 30 minut (czas bazowy) + 5 minut za każde zamówione danie. Wykonaj matematyczne wyliczenie w pamięci i podaj końcowy wynik w minutach (np. dla 3 dań jest to 30 minut). Nie podawaj wzoru, tylko ostateczny czas.
    
    Na samym końcu swojej odpowiedzi, bezwzględnie wygeneruj blok JSON ukryty w tagach <ORDER_DATA> według poniższego formatu:

    <ORDER_DATA>
    {{
    "items": ["<RZECZYWISTE_DANIE_1_Z_ROZMOWY>", "<RZECZYWISTE_DANIE_2_Z_ROZMOWY>"],
    "total_price": <RZECZYWISTA_ZSUMOWANA_KWOTA>,
    "delivery_address": "<RZECZYWISTY_KOMPLETNY_ADRES_Z_ROZMOWY>"
    }}
    </ORDER_DATA>
    """
    return prompt.strip()

def check_blacklisted_words(text: str) -> bool:
    text_lower = text.lower()
    return any(word in text_lower for word in BLACKLISTED_WORDS)

def calculate_delivery_time(items: list) -> str:
    return f"{30 + len(items) * 5} minut"

def main():
    print("Uruchomiono czatbota")
    print("")

    system_prompt = build_system_prompt(load_config(CONFIG_FILE), load_menu_from_flask())
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

            if "<ORDER_DATA>" in bot_reply:
                match = re.search(r'<ORDER_DATA>(.*?)</ORDER_DATA>', bot_reply, re.DOTALL)
                if match:
                    try:
                        order_json_str = match.group(1).strip()
                        order_data = json.loads(order_json_str)
                        
                        eta = calculate_delivery_time(order_data["items"])
                        order_data["delivery_time"] = eta
                        
                        is_success = send_order_to_flask(order_data)
                        # print("DIRTY REPLY:", bot_reply)

                        clean_reply = bot_reply.split("<ORDER_DATA>")[0].strip()
                        print(f"Bot: {clean_reply}")
                        
                        if is_success:
                            print(f"Szacowany czas dostawy to {eta}.\n")
                        else:
                            print("Błąd zapisu zamówienia\n")
    
                        continue

                    except json.JSONDecodeError:
                        print("\nBot generated invalid JSON\n")

            print(f"Bot: {bot_reply}\n")
            messages.append({"role": "assistant", "content": bot_reply})

        except KeyboardInterrupt:
            sys.exit(0)

if __name__ == "__main__":
    main()