# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Implementations
#
# backwards compatibility
@BindGlobal( "IsCapCategoryTwoCellRep", IsCapCategoryTwoCell );

####################################
##
## Operations
##
####################################

@InstallMethod( Target,
               [ IsCapCategoryTwoCell ],
               
  Range );

##
@InstallMethod( Add,
               [ IsCapCategory, IsCapCategoryTwoCell ],
               
  function( category, twocell )
    local obj_filter, filter;
    
    filter = TwoCellFilter( category );
    
    if (@not filter( twocell ))
        
        SetFilterObj( twocell, filter );
        
    end;
    
    if (HasCapCategory( twocell ))
        
        if (@not IsIdenticalObj( CapCategory( twocell ), category ))
            
            Error(
                @Concatenation(
                    "a two cell that lies in the CAP-category with the name\n",
                    Name( CapCategory( twocell ) ),
                    "\n",
                    "was tried to be added to a different CAP-category with the name\n",
                    Name( category ), ".\n",
                    "(Please note that it is possible for different CAP-categories to have the same name)"
                )
            );
            
        end;
        
    else
        
        SetCapCategory( twocell, category );
        
    end;
    
    AddMorphism( category, Source( twocell ) );
    
    AddMorphism( category, Range( twocell ) );
    
end );

##
@InstallMethod( AddTwoCell,
               [ IsCapCategory, IsCapCategoryTwoCell ],
               
  function( category, twocell )
    
    Add( category, twocell );
    
end );

##
@InstallMethod( AddTwoCell,
               [ IsCapCategory, IsAttributeStoringRep ],
               
  function( category, twocell )
    
    SetFilterObj( twocell, IsCapCategoryTwoCell );
    
    Add( category, twocell );
    
end );

##
@InstallGlobalFunction( CreateCapCategoryTwoCellWithAttributes,
                       
  function( category, source, range, additional_arguments_list... )
    local arg_list;
    
    arg_list = @Concatenation(
        [ category.two_cell_type, CapCategory, category, Source, source, Range, range ], additional_arguments_list
    );
    
    return CallFuncList( CreateGapObjectWithAttributes, arg_list );
    
end );
