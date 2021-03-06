--  Abstract :
--
--  body compatible with GNAT GPL 2016 or later via gnatprep
--
--  Copyright (C) 2017, 2018 Free Software Foundation, Inc.
--
--  This library is free software;  you can redistribute it and/or modify it
--  under terms of the  GNU General Public License  as published by the Free
--  Software  Foundation;  either version 3,  or (at your  option) any later
--  version. This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN-
--  TABILITY or FITNESS FOR A PARTICULAR PURPOSE.

pragma License (GPL);
separate (Gpr_Query)
procedure Process_Refresh (Args : GNATCOLL.Arg_Lists.Arg_List)
is
   pragma Unreferenced (Args);
begin
   Parse_All_LI_Files
     (Self                => Xref,
#if HAVE_GNATCOLL_XREF="no"
      Tree                => Tree,
#end if;
      Project             => Tree.Root_Project,
      Parse_Runtime_Files => False,
      Show_Progress       => Progress_Reporter,
      ALI_Encoding        => ALI_Encoding.all,
      From_DB_Name        => Nightly_DB_Name.all,
      To_DB_Name          => DB_Name.all,
      Force_Refresh       => Force_Refresh);
end Process_Refresh;
