#!/bin/bash

declare -a board=(
    "_" "_" "_"
    "_" "_" "_"
    "_" "_" "_"
)
declare selected_field=4
declare player="X"
declare computer=""
declare winner=""
declare additional_info=""

start_game() {

    check_winner() {

        calculate_winner() {
            for i in {0..2}; do
                if [ "${board[$((i * 3))]}" != "_" ] && [ "${board[$((i * 3))]}" == "${board[$((i * 3 + 1))]}" ] && [ "${board[$((i * 3 + 1))]}" == "${board[$((i * 3 + 2))]}" ]; then
                    winner="${board[$((i * 3))]}"
                    return 0
                fi
            done

            for i in {0..2}; do
                if [ "${board[$i]}" != "_" ] && [ "${board[$i]}" == "${board[$((i + 3))]}" ] && [ "${board[$((i + 3))]}" == "${board[$((i + 6))]}" ]; then
                    winner="${board[$i]}"
                    return 0
                fi
            done

            if [ "${board[0]}" != "_" ] && [ "${board[0]}" == "${board[4]}" ] && [ "${board[4]}" == "${board[8]}" ]; then
                winner="${board[0]}"
                return 0
            fi
            if [ "${board[2]}" != "_" ] && [ "${board[2]}" == "${board[4]}" ] && [ "${board[4]}" == "${board[6]}" ]; then
                winner="${board[2]}"
                return 0
            fi

            for i in {0..8}; do
                if [ "${board[$i]}" == "_" ]; then
                    return 1
                fi
            done   

            winner="DRAW"
            return 0
        }

        calculate_winner
        if [ "$winner" == "X" ] || [ "$winner" == "O" ]; then
            additional_info="Player $winner wins!\nPress 'q' to quit."
            selected_field=-1
        elif [ "$winner" == "DRAW" ]; then
            additional_info="It's a draw!\nPress 'q' to quit."
            selected_field=-1
        fi
        return 1
    }

    print_info() {
        echo "Press 'wsad' to select a field"
        echo "Press 'q' to quit"
        echo "Press 'e' to confirm"
        echo "Press 'r' to save game"
        echo ""
        echo ""
        if [ "$winner" == "" ]; then
            echo "Player ${player}'s turn"
        else 
            echo ""
        fi
        echo ""
    }

    print_board() {

        print_row_separator() {
            echo "-------------+-------------+-------------"
        }

        print_row() {
            local -a letter_O=(
                " ####### " 
                "##     ##"
                "##     ##"
                "##     ##"
                "##     ##"
                "##     ##"
                " ####### "
            )
            local -a letter_X=(
                "##     ##"
                " ##   ## "
                "  ## ##  "
                "   ###   "
                "  ## ##  "
                " ##   ## "
                "##     ##"
            )
            local -a letter_empty=(
                "         "
                "         "
                "         "
                "         "
                "         "
                "         "
                "         "
            )

            local empty_cell="             "
            local selected_cell_outer="*************"
            local selected_cell_inner="*           *"
            local selected_id="-1"

            if [ "$#" -eq 4 ]; then
                selected_id=$4
            fi

            local first_row=""
            local second_row=""
            if [ "$selected_id" -eq "-1" ]; then
                first_row+="$empty_cell|$empty_cell|$empty_cell"
                second_row+="$empty_cell|$empty_cell|$empty_cell"
            elif [ "$selected_id" -eq "0" ]; then
                first_row+="$selected_cell_outer|$empty_cell|$empty_cell"
                second_row+="$selected_cell_inner|$empty_cell|$empty_cell"
            elif [ "$selected_id" -eq "1" ]; then
                first_row+="$empty_cell|$selected_cell_outer|$empty_cell"
                second_row+="$empty_cell|$selected_cell_inner|$empty_cell"
            elif [ "$selected_id" -eq "2" ]; then
                first_row+="$empty_cell|$empty_cell|$selected_cell_outer"
                second_row+="$empty_cell|$empty_cell|$selected_cell_inner"
            fi

            local -a first_letter=()
            local -a second_letter=()
            local -a third_letter=()

            if [ "$1" == "O" ]; then
                first_letter=("${letter_O[@]}")
            elif [ "$1" == "X" ]; then
                first_letter=("${letter_X[@]}")
            else
                first_letter=("${letter_empty[@]}")
            fi

            if [ "$2" == "O" ]; then
                second_letter=("${letter_O[@]}")
            elif [ "$2" == "X" ]; then
                second_letter=("${letter_X[@]}")
            else
                second_letter=("${letter_empty[@]}")
            fi

            if [ "$3" == "O" ]; then
                third_letter=("${letter_O[@]}")
            elif [ "$3" == "X" ]; then
                third_letter=("${letter_X[@]}")
            else
                third_letter=("${letter_empty[@]}")
            fi

            echo "$first_row"
            echo "$second_row"

            for i in {0..6}; do
                if [ "$selected_id" -eq "-1" ]; then
                    echo "  ${first_letter[$i]}  |  ${second_letter[$i]}  |  ${third_letter[$i]}"
                elif [ "$selected_id" -eq "0" ]; then
                    echo "* ${first_letter[$i]} *|  ${second_letter[$i]}  |  ${third_letter[$i]}"
                elif [ "$selected_id" -eq "1" ]; then
                    echo "  ${first_letter[$i]}  |* ${second_letter[$i]} *|  ${third_letter[$i]}"
                elif [ "$selected_id" -eq "2" ]; then
                    echo "  ${first_letter[$i]}  |  ${second_letter[$i]}  |* ${third_letter[$i]} *"
                fi
            done

            echo "$second_row"
            echo "$first_row"
        }

        if [ "$selected_field" -ge 0 ] && [ "$selected_field" -le 2 ]; then
            print_row "${board[0]}" "${board[1]}" "${board[2]}" $((selected_field % 3))
        else 
            print_row "${board[0]}" "${board[1]}" "${board[2]}"
        fi

        print_row_separator

        if [ "$selected_field" -ge 3 ] && [ "$selected_field" -le 5 ]; then
            print_row "${board[3]}" "${board[4]}" "${board[5]}" $((selected_field % 3))
        else 
            print_row "${board[3]}" "${board[4]}" "${board[5]}"
        fi

        print_row_separator

        if [ "$selected_field" -ge 6 ] && [ "$selected_field" -le 8 ]; then
            print_row "${board[6]}" "${board[7]}" "${board[8]}" $((selected_field % 3))
        else 
            print_row "${board[6]}" "${board[7]}" "${board[8]}"
        fi
    }

    handle_input() {
        if [ "$winner" != "" ]; then
            case $1 in
                'r')
                    save_game
                    ;;
            esac
        else 
            case $1 in
                'w')
                    if [ "$selected_field" -ge 3 ]; then
                        selected_field=$((selected_field - 3))
                    fi
                    additional_info=""
                    ;;
                's')
                    if [ "$selected_field" -le 5 ]; then
                        selected_field=$((selected_field + 3))
                    fi
                    additional_info=""
                    ;;
                'a')
                    if [ $((selected_field % 3)) -ne 0 ]; then
                        selected_field=$((selected_field - 1))
                    fi
                    additional_info=""
                    ;;
                'd')
                    if [ $((selected_field % 3)) -ne 2 ]; then
                        selected_field=$((selected_field + 1))
                    fi
                    additional_info=""
                    ;;
                'e')
                    handle_turn
                    ;;
                'r')
                    save_game
                    ;;
            esac
        fi
    }

    handle_turn() {
        if [ "${board[$selected_field]}" == "_" ]; then
            board[selected_field]=$player
            if [ "$player" == "X" ]; then
                player="O"
            else
                player="X"
            fi
            additional_info=""

            check_winner
        else
            additional_info="Field already taken. Please select another one."
        fi
    }   

    handle_computer_move() {
        echo -n "Computer is thinking"
        sleep 0.5
        echo -n "."
        sleep 0.5
        echo -n "."
        sleep 0.5
        echo "."
        sleep 0.5

        local -a empty_fields=()
        for i in {0..8}; do
            if [ "${board[$i]}" == "_" ]; then
                empty_fields+=("$i")
            fi
        done

        local random_index=$((RANDOM % ${#empty_fields[@]}))
        local random_field=${empty_fields[$random_index]}
        board[random_field]="$computer"

        if [ "$player" == "X" ]; then
            player="O"
        else
            player="X"
        fi
        additional_info=""
        check_winner
    }

    game_loop() {
        while true; do
            while read -r -t 0.001 -n 10000 _; do :; done   # cleaning input buffer

            local previous_selected_field=$selected_field
            if [ "$player" == "$computer" ]; then
                selected_field=-1
            fi

            clear
            print_info
            print_board
            echo ""

            if [ "$player" == "$computer" ] && [ "$winner" == "" ]; then
                stty -echo
                handle_computer_move
                stty sane

                if [ "$winner" != "" ]; then
                    selected_field=-1
                else
                    selected_field=$previous_selected_field
                fi
            else 
                echo -e "$additional_info"
                read -rsn1 input
                if [ "$input" == "q" ]; then
                    break
                fi
                handle_input "$input"
            fi

        done 
    }

    game_loop
}

start_new_game() {
    clear_game
    if [ "$#" -eq 1 ]; then
        computer="$1" 
    fi
    start_game
}

clear_game() {
    board=(
        "_" "_" "_"
        "_" "_" "_"
        "_" "_" "_"
    )
    selected_field=4
    player="X"
    computer=""
    winner=""
    additional_info=""
}

save_game() {
    if [ "$winner" != "" ]; then
        if [ "$winner" == "X" ] || [ "$winner" == "O" ]; then
            additional_info="Player $winner wins!\nPress 'q' to quit."
            selected_field=-1
        elif [ "$winner" == "DRAW" ]; then
            additional_info="It's a draw!\nPress 'q' to quit."
            selected_field=-1
        fi
        additional_info+="\n\nGame cannot be saved after it has ended."
        return 1
    fi

    rm -f game.save
    for i in {0..8}; do
        echo "${board[$i]}" >> game.save
    done
    echo "$player" >> game.save
    echo "$computer" >> game.save
    additional_info="Game saved!"
    return 0
}

load_game() {
    if [ -f game.save ]; then
        i=0
        board=()
        while read -r line; do
            board[i]=$line
            i=$((i + 1))
            if [ $i -eq 9 ]; then
                break
            fi
        done < game.save
        player=$(tail -n 2 game.save | head -n 1)
        computer=$(tail -n 1 game.save)
        selected_field=4
        winner=""
        additional_info=""
        check_winner
        return 0
    else
        return 1
    fi
}

computer_menu() {
    while true; do
        clear 
        echo "Choose the player:"
        echo "1. Player X (first move)"
        echo "2. Player O (second move)"
        echo ""

        read -rsn1 input
        local game_started=0
        case $input in
            '1')
                game_started=1
                start_new_game "O"
                ;;
            '2')
                game_started=1
                start_new_game "X"
                ;;
        esac

        if [ $game_started -eq 1 ]; then
            break
        fi
    done
}

main_menu() {
    local save_info=""
    while true; do
        clear
        echo "Welcome to Tic-Tac-Toe!"
        echo ""
        echo "Press the number of the option you want to select:"
        echo "1. Start new game"
        echo "2. Start new game (with computer)"
        echo "3. Load saved game"
        echo "4. Delete saved game"
        echo "5. Quit"
        echo ""
        echo "$save_info"

        read -rsn1 input
        case $input in
            '1')
                save_info=""
                start_new_game
                ;;
            '2')
                save_info=""
                computer_menu
                ;;
            '3')
                load_game
                if_save_exists=$?
                if [ $if_save_exists -eq 0 ]; then
                    save_info=""
                    start_game
                else
                    save_info="No saved game found!"
                fi
                ;;
            '4')
                if [ -f game.save ]; then
                    rm -f game.save
                    save_info="Saved game deleted!"
                else
                    save_info="Cannot delete saved game. No saved game found!"
                fi 
                ;;
            '5')
                clear
                tput cnorm
                exit 0
                ;;
        esac
    done
}

tput civis
main_menu