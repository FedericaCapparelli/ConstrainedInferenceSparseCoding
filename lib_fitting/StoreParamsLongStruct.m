function OPT_PAR_matlab = StoreParamsLongStruct(n, params_set_estimated, R2, OPT_PAR_matlab) 
    OPT_PAR_matlab(n).spatialFrequency  = params_set_estimated(1);
    OPT_PAR_matlab(n).orientation       = mod(params_set_estimated(2), pi);
    OPT_PAR_matlab(n).phase             = params_set_estimated(3);
    OPT_PAR_matlab(n).center_x          = params_set_estimated(4);
    OPT_PAR_matlab(n).center_y          = params_set_estimated(5);
    OPT_PAR_matlab(n).ori_gabor         = params_set_estimated(2);
    OPT_PAR_matlab(n).width_x           = params_set_estimated(6);
    OPT_PAR_matlab(n).width_y           = params_set_estimated(7);
    OPT_PAR_matlab(n).contrast          = params_set_estimated(8);
    OPT_PAR_matlab(n).offset            = params_set_estimated(9);
    OPT_PAR_matlab(n).R2fit             = R2;
end