init 0 python:
    # the original implementation is `int(renpy.version().split(".")[1]) > 10`
    # which does not take into account the major version
    def is_glrenpy():
        return renpy.version_tuple > (6, 10)
