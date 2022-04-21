import 'dart:math';

import 'cell.dart';

class Board {
  final int height;
  final int width;
  late List<List<Cell>> cells;

  final double density;

  final Random _rand = Random();

  Board({this.height = 8, this.width = 8, this.density = 0.5});

  void _generateNewBoard() {
    cells = [];
    for (int i = 0; i < height; i++) {
      List<Cell> row = [];
      for (int j = 0; j < width; j++) {
        row.add(Cell(value: _rand.nextDouble() <= density));
      }
      cells.add(row);
    }
  }

  void _iterateOnSquare<T>(List<List<T>> list, int i, int j, void Function(T, int, int) callback) {
    for (int k = -1; k < 2; k++) {
      final targetI = i + k;
      if (targetI >= 0 && targetI < list.length) {
        for (int n = -1; n < 2; n++) {
          final targetJ = j + n;
          if (targetJ >= 0 && targetJ < list[targetI].length) {
            callback(list[targetI][targetJ], targetI, targetJ);
          }
        }
      }
    }
  }

  int _getSquareValue(int i, int j) {
    var counter = 0;
    _iterateOnSquare(cells, i, j, (Cell cell, targetI, targetJ) => counter += cell.value ? 1 : 0);
    return counter;
  }

/*
  static char *new_game_desc(const game_params *params, random_state *rs,
                           char **aux, bool interactive)
{
    bool *image = snewn(params->height * params->width, bool);
    bool valid = false;
    char *desc_string = snewn((params->height * params->width) + 1, char);
    char *compressed_desc =
        snewn((params->height * params->width) + 1, char);
    char space_count;

    struct desc_cell *desc =
        snewn(params->height * params->width, struct desc_cell);
    int x, y, location_in_str;

    while (!valid) {
        generate_image(params, rs, image);
#ifdef DEBUG_IMAGE
        image[0] = 1;
        image[1] = 1;
        image[2] = 0;
        image[3] = 1;
        image[4] = 1;
        image[5] = 0;
        image[6] = 0;
        image[7] = 0;
        image[8] = 0;
#endif

        for (y = 0; y < params->height; y++) {
            for (x = 0; x < params->width; x++) {
                populate_cell(params, image, x, y,
                              x * y == 0 || y == params->height - 1 ||
                              x == params->width - 1,
                              &desc[(y * params->width) + x]);
            }
        }
        valid =
            start_point_check((params->height - 1) * (params->width - 1),
                              desc);
        if (!valid) {
#ifdef DEBUG_PRINTS
            printf("Not valid, regenerating.\n");
#endif
        } else {
            valid = solve_check(params, desc, rs, NULL);
            if (!valid) {
#ifdef DEBUG_PRINTS
                printf("Couldn't solve, regenerating.");
#endif
            } else {
                hide_clues(params, desc, rs);
            }
        }
    }
    location_in_str = 0;
    for (y = 0; y < params->height; y++) {
        for (x = 0; x < params->width; x++) {
            if (desc[(y * params->width) + x].shown) {
#ifdef DEBUG_PRINTS
                printf("%d(%d)", desc[(y * params->width) + x].value,
                       desc[(y * params->width) + x].clue);
#endif
                sprintf(desc_string + location_in_str, "%d",
                        desc[(y * params->width) + x].clue);
            } else {
#ifdef DEBUG_PRINTS
                printf("%d( )", desc[(y * params->width) + x].value);
#endif
                sprintf(desc_string + location_in_str, " ");
            }
            location_in_str += 1;
        }
#ifdef DEBUG_PRINTS
        printf("\n");
#endif
    }
    location_in_str = 0;
    space_count = 'a' - 1;
    for (y = 0; y < params->height; y++) {
        for (x = 0; x < params->width; x++) {
            if (desc[(y * params->width) + x].shown) {
                if (space_count >= 'a') {
                    sprintf(compressed_desc + location_in_str, "%c",
                            space_count);
                    location_in_str++;
                    space_count = 'a' - 1;
                }
                sprintf(compressed_desc + location_in_str, "%d",
                        desc[(y * params->width) + x].clue);
                location_in_str++;
            } else {
                if (space_count <= 'z') {
                    space_count++;
                } else {
                    sprintf(compressed_desc + location_in_str, "%c",
                            space_count);
                    location_in_str++;
                    space_count = 'a' - 1;
                }
            }
        }
    }
    if (space_count >= 'a') {
        sprintf(compressed_desc + location_in_str, "%c", space_count);
        location_in_str++;
    }
    compressed_desc[location_in_str] = '\0';
#ifdef DEBUG_PRINTS
    printf("compressed_desc: %s\n", compressed_desc);
#endif
    return compressed_desc;
}
   */

}
