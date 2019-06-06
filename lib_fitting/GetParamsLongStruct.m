function param = GetParamsLongStruct(n, OPT_PAR_LongStruct)
param = [...
    OPT_PAR_LongStruct(n).spatialFrequency ...
    OPT_PAR_LongStruct(n).ori_gabor ...
    OPT_PAR_LongStruct(n).phase ...
    OPT_PAR_LongStruct(n).center_x...
    OPT_PAR_LongStruct(n).center_y...
    OPT_PAR_LongStruct(n).width_x ...
    OPT_PAR_LongStruct(n).width_y...
    OPT_PAR_LongStruct(n).contrast...
    OPT_PAR_LongStruct(n).offset...
    ];
end