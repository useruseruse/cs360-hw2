<%@ include file="header.jsp" %>
<%@ include file="session_check.jsp" %>
<a href="/logout.jsp"><%=user_id%> Logout</a>

<h1> Schedule </h1>

<label for="search"> Search: </label>
<input type="text" name="search" id="search">
<br><br>

<table id="schetable" border="1" style="text-align:center">
    <thead> <td>Code</td><td>Name</td><td>Start time</td><td>End time</td><td>Day of the Week</td></thead>
    <tbody>
    </tbody>
</table>

<h1> Form </h1>
<label for="name"> Name </label>
<input type="text"  name="name"  id="name"><br>
<label for="start"> Start time </label>
<input type="number" name="start" id="start" min="0" max="23"> <br>
<label for="end"> End time </label>
<input type="number" name="end"  id="end" min="1" max="24"><br>
<label for="dow"> Day of the week </label>
<select name="dow" id="dow">
    <option value="Sun"> Sun </option>
    <option value="Mon"> Mon </option>
    <option value="Tue"> Tue </option>
    <option value="Wed"> Wed </option>
    <option value="Thu"> Thu </option>
    <option value="Fri"> Fri </option>
    <option value="Sat"> Sat </option>
</select> <br>
<button id="submit_btn">Submit</button>


<script>
    const schetable = $('#schetable');
    const searchInput = $('#search');

    function append_tr(obj) {
        const tbody = schetable.children('tbody');
        let tr = $('<tr>');

        for (const key of ['code', 'name', 'start', 'end', 'dow'])
        {
            let td = $('<td>');
    
            td.attr('code', obj['code']);
            td.text(obj[key]);

            if (key == 'code')
                td.click(del_func);

            tr.append(td);
        }
        tbody.append(tr);
    }

    function delete_tr(tr) {
        tr.remove();
    }

    function clear_table() {
        schetable.children('tbody').html('');
    }

    function del_func (event) {
        //
    }

    function refresh_table() {
        // your codes here

    }

    // your codes here
    $('#submit_btn').click( function() {
        const name = $('#name').val();
        const start = $('#start').val();
        const end = $('#end').val();
        const dow = $('#dow').val();
        
        const data = {
            'name': name,
            'start': start,
            'end': end,
            'dow': dow
        };

        $.ajax({
            type: 'POST',
            url: "/sche_insert.jsp",
            data: data,
            success: function(res) {
                //[implement] table 내용 저장. 
                append_tr({
                    code: res.code,
                    name: name,
                    start: start,
                    end: end,
                    dow: dow
                });
            }
        })
    });

</script>
<%@ include file="footer.jsp" %>