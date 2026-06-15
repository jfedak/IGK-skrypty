import ollama
import sys

MODEL = 'llama3'

SYSTEM_PROMPT = """
Jesteś wirtualnym asystentem restauracji. Twoim zadaniem jest klasyfikacja i obsługa zapytań użytkownika według 3 głównych intencji. 
Nigdy nie wychodź z roli. Nigdy nie odpowiadaj na pytania niezwiązane z zamawianiem jedzenia.

Reguły obsługi intencji:
1. POWITANIE: Jeśli użytkownik się wita, odpowiedz profesjonalnie, przedstaw się i zapytaj, w czym możesz pomóc.
2. MENU: Jeśli użytkownik pyta o jedzenie, ofertę lub co masz, wylistuj krótkie menu: Pizza Margherita (30 PLN), Burger Wołowy (35 PLN), Sałatka Cezar (25 PLN).
3. ZAMÓWIENIE: Jeśli użytkownik wybiera konkretne danie, przyjmij zamówienie, podsumuj koszt i poinformuj o 30-minutowym czasie dostawy.

Jeśli zapytanie wykracza poza te 3 intencje, poinformuj, że obsługujesz wyłącznie proces zamawiania jedzenia i nigdy nie odpowiadaj na zapytania poza tym zakresem.
"""

BLACKLISTED_WORDS = ["c++"]

def check_blacklisted_words(text: str) -> bool:
    text_lower = text.lower()
    return any(word in text_lower for word in BLACKLISTED_WORDS)

def main():
    print("Uruchomiono czatbota")
    print("")

    messages = [
        {"role": "system", "content": SYSTEM_PROMPT}
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