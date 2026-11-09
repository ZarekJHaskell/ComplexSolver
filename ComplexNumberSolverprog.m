function [struct] = convert(struct) %beginning of the function junction 
    if strcmp(struct.type,  'rectangular')
        struct.theta = atan2(struct.imag/struct.real);
        struct.mag = sqrt(struct.real^2+struct.imag^2);
        struct.real = 0;
        struct.imag = 0;
        struct.type = 'exponential'; 
    else
        struct.real = struct.mag*cos(struct.theta);
        struct.imag = struct.mag*sin(struct.theta);
        struct.mag = 0;
        struct.theta = 0;
        struct.type = 'rectangular';
    end
end
function [costring] = search(direction, string, startingindex) %searches ahead or behind to store the coefficient
    costring = '';
    if direction == '-'
        while string(startingindex) ~= '+' && string(startingindex) ~= '*' && string(startingindex) ~= '-' && string(startingindex) ~= '/'%find the coefficient
            costring = string(startingindex) + costring;
            if startingindex~=1
                startingindex=startingindex-1;
                if string(startingindex) == '-'
                    costring = '-' + costring;
                end
            else
                break
            end
        end
    
    else
        if string(startingindex) ~=1 %find the negative sign
            while string(startingindex) ~= '+' && string(startingindex) ~= '-' && string(startingindex) ~= '/' && string(startingindex) ~= '*'
                if startingindex ~= 1
                    startingindex =startingindex - 1;
                    if string(startingindex) == '-'
                        costring = '-';
                    end
                else
                    break
                end
            end
        end
        while string(startingindex) ~= '+' && string(startingindex) ~= '*' && string(startingindex) ~= '-' && string(startingindex) ~= '/' %find the coefficient
            costring = costring + string(startingindex) ;
            if startingindex~=strlength(string)
                startingindex=startingindex+1;
            else
                break
            end
        end
    end
    if strcmp(costring, '-') || strcmp(costring, '')
        costring = costring + '1';
    end
    costring = str2double(costring);
end
   
function[struct] = findco(struct,string,startindex,type)%look left and right
     while string(startindex) ~= '+' && string(startindex) ~= '*' && string(startindex) ~= '-' && string(startindex) ~= '/' 
        if startindex == 1
           [struct.(type)] = search('+',string,startindex);
                
        elseif startindex == strlength(string)
            [struct.(type)] = search('-',string,startindex);
        else
            struct.(type) = search('+',string,startindex)+ search('-',string,startindex);
        end
     end

end
    

exponential = false;
equation = input('Show me what you got ARGGGH!','s');
positions = [];
structinposition = [];
operators = [];
substring = "";
structcount = 1;
elist = strfind(equation, 'e');
jlist = strfind(equation, 'j');
equation = strrep(equation,'pi',num2str(pi));
disp(equation);
function[position] = findposition(list, i)
    for y = length(list):-1:1
        if list(y) < i
            position = list(y);
            break
        end
    end
end
function[substring,structinposition,positions,operators] = modplacements(list,i,structinposition,positions,operators,structcount, equation)
    structinposition(structcount) = structcount;
    positions(structcount) = findposition(list,i);
    operators(structcount) = equation(i);
    substring ="";
end
disp(class(substring))
for i = 1:1:strlength(equation)
    disp(i)
    if equation(i) == "/" && exponential == true || equation(i) == "*" && exponential == true
        leftside = search("-",equation,findposition(jlist,i));
        rightside = search("+",equation,findposition(jlist,i));
        if equation(i) == "/"
            struct(structcount).theta = leftside/rightside;
        elseif equation(i) == "*"
            struct(structcount).theta = leftside*rightside;
        end
    elseif equation(i) ~= "+" && equation(i) ~= "-" && equation(i) ~= "*" && equation(i) ~= "/"
        substring = substring + equation(i);
        if equation(i) == 'e'
            exponential = true;
        elseif equation(i) == ")"
            exponential = false;
        end
    elseif equation(i) == "-" && i == 1
        substring = "-" + substring;
    else
        if contains(substring, 'e')
            struct(structcount).type = 'exponential';
            [substring,structinposition,positions,operators]=modplacements(elist,i,structinposition,positions,operators,structcount,equation);
            struct(structcount) = findco(struct(structcount), equation, findposition(elist,i),"mag");
            if isempty(struct(structcount).theta)
                struct(structcount).theta = findco(struct(structcount), equation, findposition(jlist,i),"theta");
            end
            structcount = structcount +1;
           
        
        elseif contains(substring, 'j')
            struct(structcount).type = 'rectnagular';
            [substring,structinposition,positions,operators]=modplacements(jlist,i,structinposition,positions,operators,structcount,equation);
            struct(structcount) =findco(struct(structcount),equation, findposition(jlist,i),"mag");
            struct(structcount) = convert(struct(structcount));
            structcount = structcount +1;
        else

        end
    end
    disp(substring)
end

