#ifndef L_DATABASE_H_
#define L_DATABASE_H_

#include <hiredis.h>
#include "lua_api/l_base.h"

class ModApiDataBase : public ModApiBase {
private:

public:
    static void Initialize(lua_State *L, int top);

private:
};


#endif
