#ifndef PSEUDO_H_
#define PSEUDO_H_

#include <vector>

#include "as.h"

void replace_pseudo_instructions(std::vector<loc>& locs, loc& l);

void load_pseudo_instructions();

#endif /* PSEUDO_H_ */
