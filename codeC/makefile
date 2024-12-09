# Définition des variables
CC = gcc
CFLAGS = -Wall -Wextra
TARGET = programme
SRCS = main.c
OBJS = $(SRCS:.c=.o)

# Règle par défaut
all: $(TARGET)

# Compilation du programme
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET)

# Règle générique pour les fichiers .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Nettoyage
clean:
	rm -f $(OBJS) $(TARGET)

# Pour éviter les conflits avec des fichiers du même nom
.PHONY: all clean