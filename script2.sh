#!/bin/bash

print_users() {
    awk -F: '{print $1 ": " $6}' /etc/passwd | sort
}

print_processes() {
    ps -eo pid,comm --sort=pid
}

print_help() {
    echo "Использование: $0 [опции]
Опции:
  -u, --users             Вывести список пользователей и их домашние директории
  -p, --processes         Вывести список запущенных процессов
  -h, --help              Показать это сообщение помощи
  -l PATH, --log PATH     Выводить лог в файл по указанному пути PATH
  -e PATH, --errors PATH  Выводить ошибки в файл по указанному пути PATH"
}

log_file=""
error_file=""
action=""

while [[ "$1" != "" ]]; do
    case "$1" in
        -u | --users )
            action="users"
            ;;
        -p | --processes )
            action="processes"
            ;;
        -h | --help )
            print_help
            exit 0
            ;;
        -l | --log )
            shift
            log_file="$1"
            ;;
        -e | --errors )
            shift
            error_file="$1"
            ;;
        * )
            echo "Неверная опция: $1"
            print_help
            exit 1
            ;;
    esac
    shift
done

if [[ -n "$log_file" ]] && [[ ! -w "$(dirname "$log_file")" ]]; then
    echo "Не удается записать в путь для файла лога: $log_file" >&2
    exit 1
fi

if [[ -n "$error_file" ]] && [[ ! -w "$(dirname "$error_file")" ]]; then
    echo "Не удается записать в путь для файла ошибок: $error_file" >&2
    exit 1
fi

exec 2> >(if [[ -n "$error_file" ]]; then tee -a "$error_file" >&2; else cat >&2; fi)

case $action in
    users)
        if [[ -n "$log_file" ]]; then
            print_users | tee -a "$log_file"
        else
            print_users
        fi
        ;;
    processes)
        if [[ -n "$log_file" ]]; then
            print_processes | tee -a "$log_file"
        else
            print_processes
        fi
        ;;
    *)
        echo "Не указано действие" >&2
        print_help
        exit 1
        ;;
esac
